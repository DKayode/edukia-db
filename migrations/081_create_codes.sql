-- Registre unifié des codes (edukia#247).
--
-- Un seul espace de noms pour les trois usages — PARRAINAGE, AMBASSADEUR,
-- REDUCTION — parce que l'utilisateur ne saisit qu'UN champ à l'achat. Deux
-- registres disjoints laisseraient un `ABC123` ambigu : parrainage ou remise ?
--
-- Deux formes de codes de réduction, comme demandé :
--   * un code unique utilisable n fois      → usage_max_total = n
--   * n codes uniques utilisables une fois  → une campagne génère n codes à 1
--
-- `utilisateurs.mon_code_parrainage` est CONSERVÉ : le mobile le lit, et
-- l'inscription continue de le générer. Les codes de parrainage existants sont
-- recopiés ici ; la résolution à l'achat interroge ce registre en premier et
-- retombe sur la colonne pour les comptes créés entre-temps.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées,
-- backfill en ON CONFLICT DO NOTHING.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) campagnes_codes — gabarit d'une génération en masse
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.campagnes_codes (
    id                serial        PRIMARY KEY,
    uuid              uuid          UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays              varchar(50)   NOT NULL DEFAULT 'benin',
    nom               varchar(150)  NOT NULL,
    description       text          NULL,
    prefixe           varchar(10)   NULL,
    nombre_codes      int           NOT NULL DEFAULT 0,
    remise_type       varchar(20)   NULL,
    remise_valeur     numeric(14,2) NULL,
    date_debut        timestamptz   NULL,
    date_fin          timestamptz   NULL,
    cree_par          int           NULL,
    date_creation     timestamptz   NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_campagnes_codes_pays ON public.campagnes_codes(pays);

-- ---------------------------------------------------------------------------
-- 2) codes — le registre
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.codes (
    id                        serial        PRIMARY KEY,
    uuid                      uuid          UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays                      varchar(50)   NOT NULL DEFAULT 'benin',
    code                      varchar(50)   NOT NULL,
    type                      varchar(30)   NOT NULL,
    -- Le parrain / ambassadeur. NULL pour un code promo marketing.
    proprietaire_id           int           NULL,
    libelle                   varchar(150)  NULL,
    remise_type               varchar(20)   NULL,
    remise_valeur             numeric(14,2) NULL,
    -- NULL = illimité. C'est le « pour n personnes » de l'issue.
    usage_max_total           int           NULL,
    usage_max_par_utilisateur int           NOT NULL DEFAULT 1,
    -- Compteur dénormalisé : `codes_utilisations` reste la source de vérité.
    usage_actuel              int           NOT NULL DEFAULT 0,
    date_debut                timestamptz   NULL,
    date_fin                  timestamptz   NULL,
    -- NULL = tous les plans.
    plans_eligibles           int[]         NULL,
    est_actif                 boolean       NOT NULL DEFAULT true,
    campagne_id               int           NULL,
    cree_par                  int           NULL,
    date_creation             timestamptz   NOT NULL DEFAULT now(),
    date_modification         timestamptz   NOT NULL DEFAULT now()
);

-- Unicité INSENSIBLE À LA CASSE : `promo2026` et `PROMO2026` sont le même code.
-- Sans cela, deux lignes concurrentes existeraient et la résolution dépendrait
-- de la façon dont l'utilisateur a tapé.
CREATE UNIQUE INDEX IF NOT EXISTS uq_codes_code ON public.codes(upper(code));
CREATE INDEX IF NOT EXISTS idx_codes_type         ON public.codes(type);
CREATE INDEX IF NOT EXISTS idx_codes_proprietaire ON public.codes(proprietaire_id) WHERE proprietaire_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_codes_campagne     ON public.codes(campagne_id) WHERE campagne_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_codes_pays         ON public.codes(pays);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_proprietaire') THEN
        ALTER TABLE public.codes ADD CONSTRAINT fk_codes_proprietaire
            FOREIGN KEY (proprietaire_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_campagne') THEN
        ALTER TABLE public.codes ADD CONSTRAINT fk_codes_campagne
            FOREIGN KEY (campagne_id) REFERENCES public.campagnes_codes(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_codes_type') THEN
        ALTER TABLE public.codes ADD CONSTRAINT chk_codes_type
            CHECK (type IN ('PARRAINAGE', 'AMBASSADEUR', 'REDUCTION'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_codes_remise') THEN
        ALTER TABLE public.codes ADD CONSTRAINT chk_codes_remise
            CHECK (remise_type IS NULL OR (remise_type IN ('POURCENTAGE', 'MONTANT_FIXE') AND remise_valeur >= 0));
    END IF;
    -- Un pourcentage au-delà de 100 ne veut rien dire.
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_codes_remise_pct') THEN
        ALTER TABLE public.codes ADD CONSTRAINT chk_codes_remise_pct
            CHECK (remise_type <> 'POURCENTAGE' OR remise_valeur <= 100);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_codes_usages') THEN
        ALTER TABLE public.codes ADD CONSTRAINT chk_codes_usages
            CHECK ((usage_max_total IS NULL OR usage_max_total > 0) AND usage_max_par_utilisateur > 0 AND usage_actuel >= 0);
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 3) codes_utilisations — le journal, source de vérité des compteurs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.codes_utilisations (
    id             serial        PRIMARY KEY,
    pays           varchar(50)   NOT NULL DEFAULT 'benin',
    code_id        int           NOT NULL,
    utilisateur_id int           NOT NULL,
    abonnement_id  int           NULL,
    montant_remise numeric(14,2) NOT NULL DEFAULT 0,
    date_creation  timestamptz   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_codes_utilisations_code ON public.codes_utilisations(code_id);
CREATE INDEX IF NOT EXISTS idx_codes_utilisations_user ON public.codes_utilisations(code_id, utilisateur_id);
CREATE INDEX IF NOT EXISTS idx_codes_utilisations_abo  ON public.codes_utilisations(abonnement_id) WHERE abonnement_id IS NOT NULL;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_utilisations_code') THEN
        ALTER TABLE public.codes_utilisations ADD CONSTRAINT fk_codes_utilisations_code
            FOREIGN KEY (code_id) REFERENCES public.codes(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_utilisations_utilisateur') THEN
        ALTER TABLE public.codes_utilisations ADD CONSTRAINT fk_codes_utilisations_utilisateur
            FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    -- Une utilisation suit son abonnement : l'annuler libère le code.
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_utilisations_abonnement') THEN
        ALTER TABLE public.codes_utilisations ADD CONSTRAINT fk_codes_utilisations_abonnement
            FOREIGN KEY (abonnement_id) REFERENCES public.abonnements(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 4) L'abonnement porte le code utilisé et la remise obtenue
-- ---------------------------------------------------------------------------
ALTER TABLE public.abonnements
    ADD COLUMN IF NOT EXISTS code_id        int           NULL,
    ADD COLUMN IF NOT EXISTS montant_remise numeric(14,2) NOT NULL DEFAULT 0;

CREATE INDEX IF NOT EXISTS idx_abonnements_code ON public.abonnements(code_id) WHERE code_id IS NOT NULL;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnements_code') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT fk_abonnements_code
            FOREIGN KEY (code_id) REFERENCES public.codes(id) ON DELETE SET NULL;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 5) Backfill des codes de parrainage existants
-- ---------------------------------------------------------------------------
-- Un code de parrainage n'accorde aucune remise et n'a pas de plafond d'usage :
-- il sert à désigner un bénéficiaire de commission (#246), pas à réduire un prix.
INSERT INTO public.codes (pays, code, type, proprietaire_id, usage_max_total, usage_max_par_utilisateur, est_actif)
SELECT COALESCE(pays, 'benin'), upper(mon_code_parrainage), 'PARRAINAGE', id, NULL, 1, true
  FROM public.utilisateurs
 WHERE mon_code_parrainage IS NOT NULL AND mon_code_parrainage <> ''
ON CONFLICT DO NOTHING;

COMMIT;
