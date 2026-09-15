-- Autoriser l'activation simultanee de plusieurs prestataires de paiement
-- (ex: KKiaPay + FedaPay + Stripe actifs en meme temps par pays).
-- Garantit qu'un seul mode (sandbox OU live) est actif par prestataire et par pays.

BEGIN;

-- 1) Supprimer l'ancienne contrainte qui limitait a un seul prestataire actif par pays
DROP INDEX IF EXISTS public.uq_config_paiement_pays_active;

-- 2) Creer la nouvelle contrainte : un seul mode actif par prestataire et par pays
CREATE UNIQUE INDEX IF NOT EXISTS uq_config_paiement_pays_prestataire_active
    ON public.configurations_paiement(pays, prestataire)
    WHERE est_actif = true;

-- 3) Inserer les configurations par defaut pour Stripe
INSERT INTO public.configurations_paiement (pays, prestataire, mode, devise, est_actif)
VALUES
    ('benin', 'STRIPE', 'sandbox', 'EUR', false),
    ('benin', 'STRIPE', 'live', 'EUR', false)
ON CONFLICT (pays, prestataire, mode) DO NOTHING;

COMMIT;
