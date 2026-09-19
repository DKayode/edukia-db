-- Registre unifié des codes (edukia#247).
--
-- Un code = une IDENTITÉ (la chaîne, son cycle de vie, ses quotas) plus un
-- ensemble d'EFFETS. Le type énuméré a été abandonné : « ambassadeur » n'est pas
-- une nature, c'est « commission + réduction ». Nommer chaque combinaison aurait
-- demandé 2^n valeurs pour n effets, et « abonnement offert » n'entrait dans
-- aucune.
--
-- Ce qui distingue un code de parrainage d'un code d'ambassadeur n'est donc pas
-- son effet — les deux versent une commission — mais son ORIGINE : généré à
-- l'inscription, ou créé au back-office.
--
-- Un seul espace de noms pour tous, parce que l'acheteur ne saisit qu'un champ.
-- C'est aussi la seule garantie qu'un code promo ne peut pas entrer en collision
-- avec le code de parrainage d'un utilisateur.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) campagnes_codes — gabarit d'une génération en masse
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.campagnes_codes (
    id            serial       PRIMARY KEY,
    uuid          uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays          varchar(50)  NOT NULL DEFAULT 'benin',
    nom           varchar(150) NOT NULL,
    description   text         NULL,
    prefixe       varchar(10)  NULL,
    nombre_codes  int          NOT NULL DEFAULT 0,
    -- Gabarit d'effets appliqué à chaque code généré, même forme que code_effets.
    effets        jsonb        NULL,
    date_debut    timestamptz  NULL,
    date_fin      timestamptz  NULL,
    cree_par      int          NULL,
    date_creation timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_campagnes_codes_pays ON public.campagnes_codes(pays);

-- ---------------------------------------------------------------------------
-- 2) codes — identité et cycle de vie, SANS effet
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.codes (
    id                        serial       PRIMARY KEY,
    uuid                      uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays                      varchar(50)  NOT NULL DEFAULT 'benin',
    code                      varchar(50)  NOT NULL,
    -- INSCRIPTION : généré automatiquement à la création d'un compte.
    -- ADMIN       : créé au back-office, seul ou par campagne.
    origine                   varchar(20)  NOT NULL DEFAULT 'ADMIN',
    -- Bénéficiaire d'un éventuel effet COMMISSION.
    proprietaire_id           int          NULL,
    libelle                   varchar(150) NULL,
    -- NULL = illimité. C'est le « pour n personnes » de l'issue.
    usage_max_total           int          NULL,
    usage_max_par_utilisateur int          NOT NULL DEFAULT 1,
    -- Compteur dénormalisé ; `codes_utilisations` reste la source de vérité.
    usage_actuel              int          NOT NULL DEFAULT 0,
    date_debut                timestamptz  NULL,
    date_fin                  timestamptz  NULL,
    plans_eligibles           int[]        NULL,
    est_actif                 boolean      NOT NULL DEFAULT true,
    campagne_id               int          NULL,
    cree_par                  int          NULL,
    date_creation             timestamptz  NOT NULL DEFAULT now(),
    date_modification         timestamptz  NOT NULL DEFAULT now()
);

-- Unicité INSENSIBLE À LA CASSE : `promo2026` et `PROMO2026` sont le même code.
-- Sans cela, deux lignes coexisteraient et la résolution dépendrait de la façon
-- dont l'utilisateur a tapé.
CREATE UNIQUE INDEX IF NOT EXISTS uq_codes_code ON public.codes(upper(code));
CREATE INDEX IF NOT EXISTS idx_codes_origine     ON public.codes(origine);
CREATE INDEX IF NOT EXISTS idx_codes_proprietaire ON public.codes(proprietaire_id) WHERE proprietaire_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_codes_campagne    ON public.codes(campagne_id) WHERE campagne_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_codes_pays        ON public.codes(pays);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_proprietaire') THEN
        ALTER TABLE public.codes ADD CONSTRAINT fk_codes_proprietaire
            FOREIGN KEY (proprietaire_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_campagne') THEN
        ALTER TABLE public.codes ADD CONSTRAINT fk_codes_campagne
            FOREIGN KEY (campagne_id) REFERENCES public.campagnes_codes(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_codes_origine') THEN
        ALTER TABLE public.codes ADD CONSTRAINT chk_codes_origine
            CHECK (origine IN ('INSCRIPTION', 'ADMIN'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_codes_usages') THEN
        ALTER TABLE public.codes ADD CONSTRAINT chk_codes_usages
            CHECK ((usage_max_total IS NULL OR usage_max_total > 0) AND usage_max_par_utilisateur > 0 AND usage_actuel >= 0);
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 3) code_effets — ce que le code FAIT
-- ---------------------------------------------------------------------------
-- Une ligne par effet, ses paramètres en jsonb. Ajouter un effet plus tard ne
-- touche ni ce schéma ni la mécanique de validation, qui est indifférente aux
-- effets — elle ne s'occupe que de l'identité et des quotas.
CREATE TABLE IF NOT EXISTS public.code_effets (
    id          serial      PRIMARY KEY,
    code_id     int         NOT NULL,
    effet       varchar(40) NOT NULL,
    parametres  jsonb       NULL,
    date_creation timestamptz NOT NULL DEFAULT now()
);

-- Un même effet ne peut pas être déclaré deux fois sur un code : deux
-- réductions concurrentes n'auraient pas d'ordre d'application défini.
CREATE UNIQUE INDEX IF NOT EXISTS uq_code_effets ON public.code_effets(code_id, effet);
CREATE INDEX IF NOT EXISTS idx_code_effets_effet ON public.code_effets(effet);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_code_effets_code') THEN
        ALTER TABLE public.code_effets ADD CONSTRAINT fk_code_effets_code
            FOREIGN KEY (code_id) REFERENCES public.codes(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_code_effets_effet') THEN
        ALTER TABLE public.code_effets ADD CONSTRAINT chk_code_effets_effet
            CHECK (effet IN ('REDUCTION', 'COMMISSION', 'ABONNEMENT_OFFERT'));
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 4) codes_utilisations — le journal, source de vérité des compteurs
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.codes_utilisations (
    id             serial        PRIMARY KEY,
    pays           varchar(50)   NOT NULL DEFAULT 'benin',
    code_id        int           NOT NULL,
    utilisateur_id int           NOT NULL,
    abonnement_id  int           NULL,
    montant_remise numeric(14,2) NOT NULL DEFAULT 0,
    -- Effets réellement appliqués, pour que l'historique reste lisible même si
    -- le code est modifié ensuite.
    effets_appliques jsonb       NULL,
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
-- 5) L'abonnement porte le code utilisé et la remise obtenue
-- ---------------------------------------------------------------------------
ALTER TABLE public.abonnements
    ADD COLUMN IF NOT EXISTS code_id        int           NULL,
    ADD COLUMN IF NOT EXISTS montant_remise numeric(14,2) NOT NULL DEFAULT 0,
    -- Un abonnement ouvert par un code ABONNEMENT_OFFERT n'a jamais été encaissé :
    -- il ne doit pas compter dans le chiffre d'affaires, ni déclencher de commission.
    ADD COLUMN IF NOT EXISTS offert         boolean       NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_abonnements_code ON public.abonnements(code_id) WHERE code_id IS NOT NULL;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnements_code') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT fk_abonnements_code
            FOREIGN KEY (code_id) REFERENCES public.codes(id) ON DELETE SET NULL;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 6) Backfill des codes de parrainage existants
-- ---------------------------------------------------------------------------
-- Ils gardent leur chaîne et leur propriétaire, prennent l'origine INSCRIPTION,
-- et reçoivent l'effet COMMISSION — le même que celui d'un ambassadeur, ce qui
-- est précisément la démonstration que le type énuméré était de trop.
INSERT INTO public.codes (pays, code, origine, proprietaire_id, usage_max_total, usage_max_par_utilisateur, est_actif)
SELECT COALESCE(pays, 'benin'), upper(mon_code_parrainage), 'INSCRIPTION', id, NULL, 1, true
  FROM public.utilisateurs
 WHERE mon_code_parrainage IS NOT NULL AND mon_code_parrainage <> ''
ON CONFLICT DO NOTHING;

INSERT INTO public.code_effets (code_id, effet, parametres)
SELECT c.id, 'COMMISSION', NULL
  FROM public.codes c
 WHERE c.origine = 'INSCRIPTION'
ON CONFLICT DO NOTHING;

COMMIT;
