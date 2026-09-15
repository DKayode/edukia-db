-- Corriger les bases où l'ancienne règle « un seul actif par pays »
-- est encore présente, afin d'autoriser plusieurs prestataires actifs.
-- Un seul mode (sandbox/live) reste actif par prestataire et par pays.

BEGIN;

DROP INDEX IF EXISTS public.uq_config_paiement_pays_active;

CREATE UNIQUE INDEX IF NOT EXISTS uq_config_paiement_pays_prestataire_active
    ON public.configurations_paiement(pays, prestataire)
    WHERE est_actif = true;

COMMIT;
