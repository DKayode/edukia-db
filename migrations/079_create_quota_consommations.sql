-- Quotas gratuits sur les ressources académiques (edukia#245).
--
-- Un utilisateur sans abonnement peut consulter 5 ressources DISTINCTES
-- (épreuves et examens nationaux confondus) et lancer Ketsia sur 1 seule,
-- PAR MOIS. Le quota porte sur des ressources distinctes, pas sur des accès :
-- rouvrir la même épreuve dans le mois ne recompte pas.
--
-- Deux tables :
--   * `configurations_quota`  — les plafonds, réglables depuis le back-office ;
--     les coder en dur obligerait à redéployer pour changer un chiffre commercial.
--   * `quota_consommations`   — les consommations, datées par période.
--
-- Cette dernière est DISTINCTE de `resource_access`, à dessein : celle-ci est un
-- journal de KPI best-effort dont les INSERT échouent en silence et sans
-- unicité. Un quota assis dessus sauterait sans bruit.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) configurations_quota — plafonds administrables
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.configurations_quota (
    id                serial       PRIMARY KEY,
    uuid              uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays              varchar(50)  NOT NULL DEFAULT 'benin',
    feature           varchar(40)  NOT NULL,
    limite            int          NOT NULL,
    -- MENSUEL : remise à zéro le 1er de chaque mois. AVIE : jamais.
    periode_reset     varchar(20)  NOT NULL DEFAULT 'MENSUEL',
    est_actif         boolean      NOT NULL DEFAULT true,
    date_creation     timestamptz  NOT NULL DEFAULT now(),
    date_modification timestamptz  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_configurations_quota_pays_feature
    ON public.configurations_quota(pays, feature);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_config_quota_feature') THEN
        ALTER TABLE public.configurations_quota ADD CONSTRAINT chk_config_quota_feature
            CHECK (feature IN ('RESOURCE_VIEW', 'KETSIA_AI'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_config_quota_periode') THEN
        ALTER TABLE public.configurations_quota ADD CONSTRAINT chk_config_quota_periode
            CHECK (periode_reset IN ('MENSUEL', 'AVIE'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_config_quota_limite') THEN
        ALTER TABLE public.configurations_quota ADD CONSTRAINT chk_config_quota_limite
            CHECK (limite >= 0);
    END IF;
END $$;

INSERT INTO public.configurations_quota (pays, feature, limite, periode_reset, est_actif)
VALUES ('benin', 'RESOURCE_VIEW', 5, 'MENSUEL', true),
       ('benin', 'KETSIA_AI',     1, 'MENSUEL', true)
ON CONFLICT (pays, feature) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2) quota_consommations
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.quota_consommations (
    id             serial      PRIMARY KEY,
    pays           varchar(50) NOT NULL DEFAULT 'benin',
    utilisateur_id int         NOT NULL,
    feature        varchar(40) NOT NULL,
    resource_type  varchar(30) NOT NULL,
    resource_id    int         NOT NULL,
    -- 'YYYY-MM' pour un quota mensuel, 'AVIE' pour un quota non renouvelable.
    -- Stocker la période dans la LIGNE, plutôt que de filtrer sur une date à la
    -- lecture, garde l'unicité utilisable : c'est elle qui empêche la double
    -- consommation sous concurrence.
    periode        varchar(10) NOT NULL DEFAULT to_char(now(), 'YYYY-MM'),
    date_creation  timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_quota_conso
    ON public.quota_consommations(utilisateur_id, feature, resource_type, resource_id, periode);

CREATE INDEX IF NOT EXISTS idx_quota_conso_user_feature_periode
    ON public.quota_consommations(utilisateur_id, feature, periode);

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

-- ---------------------------------------------------------------------------
-- 3) resource_access connaît enfin les examens nationaux
-- ---------------------------------------------------------------------------
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
    WHEN undefined_table THEN NULL;
    WHEN duplicate_object THEN NULL;
END $$;

COMMIT;
