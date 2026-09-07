-- Encaissement des abonnements (edukia#248).
--
-- Ces tables concernent l'argent qui ENTRE dans Edukia. Elles sont séparées du
-- module wallet, qui gère les retraits et paiements sortants vers les
-- contributeurs.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) paiements — intention et état d'un encaissement
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.paiements (
    id                     serial        PRIMARY KEY,
    uuid                   uuid          UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays                   varchar(50)   NOT NULL DEFAULT 'benin',
    reference              varchar(100)  NOT NULL,
    utilisateur_id         int           NOT NULL,
    abonnement_id          int           NULL,
    montant                numeric(14,2) NOT NULL,
    devise                 varchar(10)   NOT NULL DEFAULT 'XOF',
    prestataire            varchar(30)   NOT NULL,
    methode                varchar(30)   NULL,
    statut                 varchar(30)   NOT NULL DEFAULT 'INITIE',
    reference_prestataire  varchar(150)  NULL,
    url_paiement           text          NULL,
    token_client           text          NULL,
    payload_initiation     jsonb         NULL,
    payload_confirmation   jsonb         NULL,
    message_erreur         text          NULL,
    date_expiration        timestamptz   NULL,
    date_confirmation      timestamptz   NULL,
    date_creation          timestamptz   NOT NULL DEFAULT now(),
    date_modification      timestamptz   NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_paiements_reference ON public.paiements(reference);
CREATE UNIQUE INDEX IF NOT EXISTS uq_paiements_reference_prestataire
    ON public.paiements(prestataire, reference_prestataire)
    WHERE reference_prestataire IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_paiements_utilisateur ON public.paiements(utilisateur_id);
CREATE INDEX IF NOT EXISTS idx_paiements_abonnement  ON public.paiements(abonnement_id) WHERE abonnement_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_paiements_statut      ON public.paiements(statut);
CREATE INDEX IF NOT EXISTS idx_paiements_pays        ON public.paiements(pays);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_paiements_utilisateur') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT fk_paiements_utilisateur
            FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_paiements_abonnement') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT fk_paiements_abonnement
            FOREIGN KEY (abonnement_id) REFERENCES public.abonnements(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_paiements_montant') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT chk_paiements_montant CHECK (montant >= 0);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_paiements_prestataire') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT chk_paiements_prestataire
            CHECK (prestataire IN ('KKIAPAY','FEDAPAY','CINETPAY','FLUTTERWAVE','STRIPE','REVENUECAT'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_paiements_methode') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT chk_paiements_methode
            CHECK (methode IS NULL OR methode IN ('MOBILE_MONEY','CARTE','IAP'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_paiements_statut') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT chk_paiements_statut
            CHECK (statut IN ('INITIE','EN_ATTENTE','REUSSI','ECHOUE','ANNULE','EXPIRE','REMBOURSE'));
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 2) paiement_webhooks — journal d'idempotence des callbacks PSP
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.paiement_webhooks (
    id                 serial       PRIMARY KEY,
    prestataire        varchar(30)  NOT NULL,
    evenement_id       varchar(150) NOT NULL,
    signature_valide   boolean      NOT NULL,
    payload            jsonb        NOT NULL,
    traite             boolean      NOT NULL DEFAULT false,
    erreur_traitement  text         NULL,
    date_reception     timestamptz  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_paiement_webhook_evt
    ON public.paiement_webhooks(prestataire, evenement_id);
CREATE INDEX IF NOT EXISTS idx_paiement_webhooks_traite
    ON public.paiement_webhooks(traite, date_reception);

-- ---------------------------------------------------------------------------
-- 3) configurations_paiement — prestataire actif par pays
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.configurations_paiement (
    id                 serial       PRIMARY KEY,
    uuid               uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays               varchar(50)  NOT NULL DEFAULT 'benin',
    prestataire        varchar(30)  NOT NULL,
    mode               varchar(20)  NOT NULL DEFAULT 'sandbox',
    devise             varchar(10)  NOT NULL DEFAULT 'XOF',
    montant_min        numeric(14,2) NULL,
    montant_max        numeric(14,2) NULL,
    est_actif          boolean      NOT NULL DEFAULT true,
    date_creation      timestamptz  NOT NULL DEFAULT now(),
    date_modification  timestamptz  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_config_paiement_pays_active
    ON public.configurations_paiement(pays)
    WHERE est_actif = true;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_config_paiement_prestataire') THEN
        ALTER TABLE public.configurations_paiement ADD CONSTRAINT chk_config_paiement_prestataire
            CHECK (prestataire IN ('KKIAPAY','FEDAPAY','CINETPAY','FLUTTERWAVE','STRIPE','REVENUECAT'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_config_paiement_mode') THEN
        ALTER TABLE public.configurations_paiement ADD CONSTRAINT chk_config_paiement_mode
            CHECK (mode IN ('sandbox','live'));
    END IF;
END $$;

INSERT INTO public.configurations_paiement (pays, prestataire, mode, devise, est_actif)
VALUES ('benin', 'KKIAPAY', 'sandbox', 'XOF', true)
ON CONFLICT DO NOTHING;

-- ---------------------------------------------------------------------------
-- 4) L'abonnement connaît le dernier paiement qui l'a activé ou tenté
-- ---------------------------------------------------------------------------
ALTER TABLE public.abonnements
    ADD COLUMN IF NOT EXISTS paiement_id int NULL;

CREATE INDEX IF NOT EXISTS idx_abonnements_paiement
    ON public.abonnements(paiement_id) WHERE paiement_id IS NOT NULL;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnements_paiement') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT fk_abonnements_paiement
            FOREIGN KEY (paiement_id) REFERENCES public.paiements(id) ON DELETE SET NULL;
    END IF;
END $$;

COMMIT;
