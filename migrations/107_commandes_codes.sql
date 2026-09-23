-- 107 — Achat groupé d'abonnements, distribué sous forme de codes
--
-- Un utilisateur paie N abonnements d'un coup et reçoit N codes à usage unique,
-- qu'il distribue à qui il veut : une école dote ses élèves, un parent équipe
-- ses enfants, une entreprise ses employés.
--
-- Le code lui-même n'est pas une nouveauté : le registre `codes` porte déjà
-- l'effet ABONNEMENT_OFFERT, le compte d'usages et le journal des utilisations.
-- Ce qui manquait est l'AMONT — la commande payée qui les fait naître, et le
-- lien entre le paiement et cette commande.

BEGIN;

-- ── La commande ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.commandes_codes (
    id              serial PRIMARY KEY,
    uuid            uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays            varchar(50) NOT NULL DEFAULT 'benin',
    utilisateur_id  integer NOT NULL,
    plan_id         integer NOT NULL,
    quantite        int NOT NULL,
    -- Le prix est figé à la commande. Le plan peut changer de tarif entre la
    -- commande et le paiement ; l'acheteur doit payer ce qu'on lui a annoncé.
    prix_unitaire   numeric(14,2) NOT NULL,
    montant_total   numeric(14,2) NOT NULL,
    devise          varchar(10) NOT NULL DEFAULT 'XOF',
    statut          varchar(30) NOT NULL DEFAULT 'EN_ATTENTE',
    paiement_id     integer NULL,
    date_paiement   timestamptz NULL,
    date_creation     timestamptz NOT NULL DEFAULT now(),
    date_modification timestamptz NOT NULL DEFAULT now()
);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_commandes_codes_utilisateur') THEN
        ALTER TABLE public.commandes_codes ADD CONSTRAINT fk_commandes_codes_utilisateur
            FOREIGN KEY (utilisateur_id) REFERENCES public.utilisateurs(id) ON DELETE CASCADE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_commandes_codes_plan') THEN
        ALTER TABLE public.commandes_codes ADD CONSTRAINT fk_commandes_codes_plan
            FOREIGN KEY (plan_id) REFERENCES public.plans_abonnement(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_commandes_codes_statut') THEN
        ALTER TABLE public.commandes_codes ADD CONSTRAINT chk_commandes_codes_statut
            CHECK (statut IN ('EN_ATTENTE', 'PAYEE', 'ANNULEE', 'REMBOURSEE'));
    END IF;
    -- Une quantité plafonnée : au-delà, c'est une négociation commerciale, pas
    -- un achat en libre-service. Le plafond protège aussi d'une erreur de saisie
    -- qui générerait des milliers de codes.
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_commandes_codes_quantite') THEN
        ALTER TABLE public.commandes_codes ADD CONSTRAINT chk_commandes_codes_quantite
            CHECK (quantite >= 1 AND quantite <= 500);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_commandes_codes_montants') THEN
        ALTER TABLE public.commandes_codes ADD CONSTRAINT chk_commandes_codes_montants
            CHECK (prix_unitaire >= 0 AND montant_total >= 0);
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_commandes_codes_utilisateur
    ON public.commandes_codes (utilisateur_id, date_creation DESC);
CREATE INDEX IF NOT EXISTS idx_commandes_codes_statut
    ON public.commandes_codes (pays, statut);

-- ── Le paiement peut viser une commande, pas seulement un abonnement ──────
ALTER TABLE public.paiements
    ADD COLUMN IF NOT EXISTS commande_id integer NULL;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_paiements_commande') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT fk_paiements_commande
            FOREIGN KEY (commande_id) REFERENCES public.commandes_codes(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_paiements_commande
    ON public.paiements (commande_id) WHERE commande_id IS NOT NULL;

-- ── Les codes issus d'un achat ───────────────────────────────────────────
-- Nouvelle origine : elle distingue ces codes de ceux du parrainage et du
-- back-office. La distinction n'est pas cosmétique — c'est elle qui autorise
-- l'acheteur à utiliser un de ses propres codes, ce qu'interdit la règle
-- d'auto-utilisation posée pour le parrainage.
ALTER TABLE public.codes DROP CONSTRAINT IF EXISTS chk_codes_origine;
ALTER TABLE public.codes ADD CONSTRAINT chk_codes_origine
    CHECK (origine IN ('INSCRIPTION', 'ADMIN', 'ACHAT'));

ALTER TABLE public.codes
    ADD COLUMN IF NOT EXISTS commande_id integer NULL;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_codes_commande') THEN
        ALTER TABLE public.codes ADD CONSTRAINT fk_codes_commande
            FOREIGN KEY (commande_id) REFERENCES public.commandes_codes(id) ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_codes_commande
    ON public.codes (commande_id) WHERE commande_id IS NOT NULL;

COMMENT ON TABLE public.commandes_codes IS
    'Achat groupé d''abonnements. Payée, elle engendre autant de codes à usage unique.';
COMMENT ON COLUMN public.commandes_codes.prix_unitaire IS
    'Prix du plan AU MOMENT DE LA COMMANDE. Figé : le tarif peut changer avant le paiement.';

COMMIT;
