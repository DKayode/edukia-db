-- Commission de parrainage sur les abonnements (edukia#246).
--
-- Le parrain reçoit une part du prix de l'abonnement de son filleul, créditée
-- dans son wallet. Rien de neuf côté versement : on réutilise la machinerie de
-- récompenses existante (`payment_reward_source_types` /
-- `payment_reward_configurations` / `CreditRewardSourceUseCase`), qui gère déjà
-- l'idempotence, les plafonds, la notification et l'audit.
--
-- Le type de récompense PARRAINAGE_ABONNEMENT n'est PAS semé ici : il l'est par
-- `ensureDefaults()` côté backend, comme les trois autres. Dupliquer ce seed en
-- SQL le ferait diverger au premier changement de libellé.
--
-- Idempotent : ADD COLUMN IF NOT EXISTS, contraintes gardées.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) La commission est un POURCENTAGE, pas un montant fixe
-- ---------------------------------------------------------------------------
-- `reward_amount` seul ne suffit pas : une commission suit le prix du plan.
-- Les deux colonnes cohabitent — les récompenses existantes (épreuve, examen,
-- concours) restent en montant fixe.
ALTER TABLE public.payment_reward_configurations
    ADD COLUMN IF NOT EXISTS commission_type       varchar(20)   NOT NULL DEFAULT 'FIXED',
    ADD COLUMN IF NOT EXISTS commission_percentage numeric(5,2)  NOT NULL DEFAULT 0;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_reward_config_commission_type') THEN
        ALTER TABLE public.payment_reward_configurations ADD CONSTRAINT chk_reward_config_commission_type
            CHECK (commission_type IN ('FIXED', 'PERCENTAGE'));
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_reward_config_commission_pct') THEN
        ALTER TABLE public.payment_reward_configurations ADD CONSTRAINT chk_reward_config_commission_pct
            CHECK (commission_percentage >= 0 AND commission_percentage <= 100);
    END IF;
END $$;

COMMENT ON COLUMN public.payment_reward_configurations.commission_type IS
    'FIXED : reward_amount s''applique. PERCENTAGE : commission_percentage du montant payé.';

-- ---------------------------------------------------------------------------
-- 2) Traçabilité de la commission sur l'abonnement
-- ---------------------------------------------------------------------------
-- Le parrain est FIGÉ à la souscription : un changement ultérieur de la
-- relation de parrainage ne doit pas rétro-attribuer une commission.
ALTER TABLE public.abonnements
    ADD COLUMN IF NOT EXISTS parrain_id        int     NULL,
    ADD COLUMN IF NOT EXISTS commission_versee boolean NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_abonnements_parrain
    ON public.abonnements(parrain_id) WHERE parrain_id IS NOT NULL;

-- Les abonnements payés dont la commission n'est pas passée : matière du
-- rattrapage administrateur.
CREATE INDEX IF NOT EXISTS idx_abonnements_commission_due
    ON public.abonnements(commission_versee) WHERE parrain_id IS NOT NULL AND commission_versee = false;

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_abonnements_parrain') THEN
        -- SET NULL et non CASCADE : supprimer un parrain ne doit pas emporter
        -- l'abonnement de son filleul.
        ALTER TABLE public.abonnements ADD CONSTRAINT fk_abonnements_parrain
            FOREIGN KEY (parrain_id) REFERENCES public.utilisateurs(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_abonnements_pas_auto_parrainage') THEN
        ALTER TABLE public.abonnements ADD CONSTRAINT chk_abonnements_pas_auto_parrainage
            CHECK (parrain_id IS NULL OR parrain_id <> utilisateur_id);
    END IF;
END $$;

COMMIT;
