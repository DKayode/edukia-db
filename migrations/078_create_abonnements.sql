-- Socle des abonnements (edukia#244).
--
-- Trois tables : le catalogue administrable (`plans_abonnement`), l'abonnement
-- souscrit (`abonnements`) et son journal (`abonnement_evenements`).
--
-- Les plans sont semés `est_actif = false` À DESSEIN : tant que l'encaissement
-- (#248) n'est pas livré, ouvrir le catalogue montrerait à l'utilisateur un prix
-- qu'il ne peut pas payer. On les ouvrira quand il y aura un moyen de payer.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées, seed en
-- ON CONFLICT DO NOTHING.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) plans_abonnement — le catalogue
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.plans_abonnement (
    id                serial        PRIMARY KEY,
    uuid              uuid          UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays              varchar(50)   NOT NULL DEFAULT 'benin',
    code              varchar(50)   NOT NULL,
    libelle           varchar(150)  NOT NULL,
    description       text          NULL,
    prix              numeric(14,2) NOT NULL,
    devise            varchar(10)   NOT NULL DEFAULT 'XOF',
    duree_jours       int           NOT NULL,
    est_actif         boolean       NOT NULL DEFAULT false,
    ordre_affichage   int           NOT NULL DEFAULT 0,
    date_creation     timestamptz   NOT NULL DEFAULT now(),
    date_modification timestamptz   NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_plans_abonnement_pays_code
    ON public.plans_abonnement(pays, code);
CREATE INDEX IF NOT EXISTS idx_plans_abonnement_pays
    ON public.plans_abonnement(pays);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_plans_abonnement_prix') THEN
        ALTER TABLE public.plans_abonnement ADD CONSTRAINT chk_plans_abonnement_prix
            CHECK (prix >= 0 AND duree_jours > 0);
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 2) abonnements
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.abonnements (
    id                  serial        PRIMARY KEY,
    uuid                uuid          UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays                varchar(50)   NOT NULL DEFAULT 'benin',
    utilisateur_id      int           NOT NULL,
    plan_id             int           NOT NULL,
    statut              varchar(30)   NOT NULL DEFAULT 'EN_ATTENTE',
    date_debut          timestamptz   NULL,
    date_fin            timestamptz   NULL,
    montant_paye        numeric(14,2) NOT NULL DEFAULT 0,
    devise              varchar(10)   NOT NULL DEFAULT 'XOF',
    renouvellement_auto boolean       NOT NULL DEFAULT false,
    metadata            jsonb         NULL,
    date_creation       timestamptz   NOT NULL DEFAULT now(),
    date_modification   timestamptz   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_abonnements_utilisateur ON public.abonnements(utilisateur_id);
CREATE INDEX IF NOT EXISTS idx_abonnements_pays        ON public.abonnements(pays);
CREATE INDEX IF NOT EXISTS idx_abonnements_statut      ON public.abonnements(statut);

-- Index de la question posée à chaque requête gardée : « cet utilisateur a-t-il
-- un abonnement actif non expiré ? »
CREATE INDEX IF NOT EXISTS idx_abonnements_actif
    ON public.abonnements(utilisateur_id, statut, date_fin);

-- Au plus UN abonnement actif par utilisateur. Porté par la base, pas par le
-- service : deux paiements concurrents ne doivent pas ouvrir deux abonnements.
CREATE UNIQUE INDEX IF NOT EXISTS uq_abonnement_actif_par_user
    ON public.abonnements(utilisateur_id) WHERE statut = 'ACTIF';

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnements_utilisateur') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT fk_abonnements_utilisateur
            FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnements_plan') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT fk_abonnements_plan
            FOREIGN KEY (plan_id) REFERENCES public.plans_abonnement(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_abonnements_statut') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT chk_abonnements_statut
            CHECK (statut IN ('EN_ATTENTE','ACTIF','EXPIRE','ANNULE','REMBOURSE'));
    END IF;
    -- Un abonnement ACTIF sans bornes de validité serait ininterprétable par le
    -- cron d'expiration comme par l'EntitlementService.
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_abonnements_dates_actif') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT chk_abonnements_dates_actif
            CHECK (statut <> 'ACTIF' OR (date_debut IS NOT NULL AND date_fin IS NOT NULL));
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 3) abonnement_evenements — journal append-only
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.abonnement_evenements (
    id            serial      PRIMARY KEY,
    abonnement_id int         NOT NULL,
    type          varchar(40) NOT NULL,
    payload       jsonb       NULL,
    date_creation timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_abonnement_evenements_abonnement
    ON public.abonnement_evenements(abonnement_id, date_creation);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnement_evenements_abonnement') THEN
        ALTER TABLE public.abonnement_evenements ADD CONSTRAINT fk_abonnement_evenements_abonnement
            FOREIGN KEY (abonnement_id) REFERENCES public.abonnements(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 4) Seed — plans Bénin, FERMÉS tant que #248 n'est pas livrée
-- ---------------------------------------------------------------------------
INSERT INTO public.plans_abonnement (pays, code, libelle, description, prix, devise, duree_jours, est_actif, ordre_affichage)
VALUES
    ('benin', 'MENSUEL',     'Abonnement mensuel',     'Accès illimité pendant 1 mois',   2000,  'XOF',  30, false, 1),
    ('benin', 'TRIMESTRIEL', 'Abonnement trimestriel', 'Accès illimité pendant 3 mois',   5000,  'XOF',  90, false, 2),
    ('benin', 'ANNUEL',      'Abonnement annuel',      'Accès illimité pendant 12 mois',  18000, 'XOF', 365, false, 3)
ON CONFLICT (pays, code) DO NOTHING;

COMMIT;
