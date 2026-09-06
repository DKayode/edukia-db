-- Quotas gratuits sur les ressources académiques (edukia#245).
--
-- Un utilisateur sans abonnement peut consulter 5 ressources DISTINCTES
-- (épreuves et examens nationaux confondus) et lancer Ketsia sur 1 seule.
-- Le quota porte sur des ressources distinctes, pas sur des accès : rouvrir la
-- même épreuve ne recompte pas. Il est à vie, non renouvelable — un quota
-- mensuel n'inciterait personne à s'abonner.
--
-- Table DISTINCTE de `resource_access`, à dessein. Cette dernière est un
-- journal de KPI best-effort : ses INSERT échouent en silence et rien n'y
-- garantit l'unicité. Un quota assis dessus sauterait sans bruit.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées.
BEGIN;

CREATE TABLE IF NOT EXISTS public.quota_consommations (
    id             serial      PRIMARY KEY,
    pays           varchar(50) NOT NULL DEFAULT 'benin',
    utilisateur_id int         NOT NULL,
    feature        varchar(40) NOT NULL,
    resource_type  varchar(30) NOT NULL,
    resource_id    int         NOT NULL,
    date_creation  timestamptz NOT NULL DEFAULT now()
);

-- Le cœur du dispositif : une ressource distincte n'est comptée qu'une fois.
-- C'est cette contrainte — et non le service — qui rend l'opération correcte
-- sous concurrence : deux requêtes simultanées sur la même ressource ne
-- consomment qu'une unité, la seconde tombant sur le conflit.
CREATE UNIQUE INDEX IF NOT EXISTS uq_quota_conso
    ON public.quota_consommations(utilisateur_id, feature, resource_type, resource_id);

CREATE INDEX IF NOT EXISTS idx_quota_conso_user_feature
    ON public.quota_consommations(utilisateur_id, feature);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_quota_conso_utilisateur') THEN
        ALTER TABLE public.quota_consommations ADD CONSTRAINT fk_quota_conso_utilisateur
            FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_quota_conso_feature') THEN
        ALTER TABLE public.quota_consommations ADD CONSTRAINT chk_quota_conso_feature
            CHECK (feature IN ('RESOURCE_VIEW', 'KETSIA_AI'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_quota_conso_resource_type') THEN
        ALTER TABLE public.quota_consommations ADD CONSTRAINT chk_quota_conso_resource_type
            CHECK (resource_type IN ('epreuve', 'examen_national'));
    END IF;
END $$;

-- `resource_access` ne connaissait que 'epreuve' et 'concours' : les examens
-- nationaux n'étaient journalisés nulle part, ce qui faussait aussi le KPI 16.
DO $$
DECLARE nom text;
BEGIN
    SELECT conname INTO nom FROM pg_constraint
     WHERE conrelid = 'public.resource_access'::regclass AND contype = 'c'
       AND pg_get_constraintdef(oid) ILIKE '%resource_type%';
    IF nom IS NOT NULL THEN
        EXECUTE format('ALTER TABLE public.resource_access DROP CONSTRAINT %I', nom);
    END IF;
    ALTER TABLE public.resource_access ADD CONSTRAINT chk_resource_access_type
        CHECK (resource_type IN ('epreuve', 'concours', 'examen_national'));
EXCEPTION
    WHEN undefined_table THEN NULL;   -- environnement sans resource_access
    WHEN duplicate_object THEN NULL;  -- rejouée
END $$;

COMMIT;
