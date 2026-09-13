-- Limitation des quotas gratuits par appareil (edukia#227).
--
-- Les comptes existants restent eligibles. Le defaut SQL reste permissif pour
-- que cette migration puisse preceder le backend sans penaliser les nouvelles
-- inscriptions de l'ancienne version. Le nouveau backend ecrit explicitement
-- false avant sa decision de controle d'appareil.
BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

ALTER TABLE public.utilisateurs
    ADD COLUMN IF NOT EXISTS quota_gratuit_eligible boolean;

UPDATE public.utilisateurs
SET quota_gratuit_eligible = true
WHERE quota_gratuit_eligible IS NULL;

ALTER TABLE public.utilisateurs
    ALTER COLUMN quota_gratuit_eligible SET DEFAULT true,
    ALTER COLUMN quota_gratuit_eligible SET NOT NULL;

COMMENT ON COLUMN public.utilisateurs.quota_gratuit_eligible IS
    'Autorise les quotas gratuits sans abonnement. Les abonnements payants ne sont jamais affectes.';

CREATE TABLE IF NOT EXISTS public.appareils_quota_gratuit (
    id                         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    fournisseur                varchar(40) NOT NULL,
    plateforme                 varchar(20) NOT NULL,
    installation_hash          char(64)    NOT NULL,
    inscriptions_comptabilisees integer    NOT NULL DEFAULT 0,
    compteur_fournisseur       integer     NOT NULL DEFAULT 0,
    derniere_verification      timestamptz NOT NULL DEFAULT now(),
    date_creation              timestamptz NOT NULL DEFAULT now(),
    date_modification          timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT chk_appareil_quota_fournisseur
        CHECK (fournisseur IN ('ANDROID_PLAY_INTEGRITY', 'IOS_DEVICECHECK')),
    CONSTRAINT chk_appareil_quota_plateforme
        CHECK (plateforme IN ('android', 'ios')),
    CONSTRAINT chk_appareil_quota_compteurs
        CHECK (inscriptions_comptabilisees >= 0 AND compteur_fournisseur >= 0)
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_appareil_quota_installation
    ON public.appareils_quota_gratuit(fournisseur, installation_hash);

CREATE INDEX IF NOT EXISTS idx_appareil_quota_compteur
    ON public.appareils_quota_gratuit(inscriptions_comptabilisees DESC, derniere_verification DESC);

CREATE TABLE IF NOT EXISTS public.eligibilites_quota_gratuit (
    id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    utilisateur_id     integer     NOT NULL UNIQUE,
    appareil_id        uuid        NULL,
    pays               varchar(50) NOT NULL DEFAULT 'benin',
    fournisseur        varchar(40) NULL,
    mode_controle      varchar(20) NOT NULL,
    statut             varchar(30) NOT NULL,
    eligible           boolean     NOT NULL,
    compteur_apres     integer     NULL,
    motif              varchar(80) NOT NULL,
    admin_modification_id integer   NULL,
    date_creation      timestamptz NOT NULL DEFAULT now(),
    date_modification  timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT fk_eligibilite_quota_utilisateur
        FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE,
    CONSTRAINT fk_eligibilite_quota_appareil
        FOREIGN KEY (appareil_id) REFERENCES public.appareils_quota_gratuit(id) ON DELETE SET NULL,
    CONSTRAINT fk_eligibilite_quota_admin
        FOREIGN KEY (admin_modification_id) REFERENCES public.utilisateurs(id) ON DELETE SET NULL,
    CONSTRAINT chk_eligibilite_quota_mode
        CHECK (mode_controle IN ('off', 'monitor', 'enforce')),
    CONSTRAINT chk_eligibilite_quota_statut
        CHECK (statut IN ('ACCORDEE', 'REFUSEE', 'OBSERVATION', 'SANS_PREUVE', 'ERREUR_PREUVE', 'DECISION_ADMIN'))
);

CREATE INDEX IF NOT EXISTS idx_eligibilite_quota_appareil
    ON public.eligibilites_quota_gratuit(appareil_id, date_creation DESC);

CREATE INDEX IF NOT EXISTS idx_eligibilite_quota_refusee
    ON public.eligibilites_quota_gratuit(date_creation DESC)
    WHERE eligible = false;

COMMIT;
