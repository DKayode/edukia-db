-- Ajouter RevenueCat comme prestataire d'abonnements in-app.
-- L'achat est effectué par le SDK mobile ; le backend reçoit les webhooks.

BEGIN;

-- Do not use ON CONFLICT here: production installations use a partial
-- unique index for active providers, not a unique constraint on these three
-- columns.  NOT EXISTS stays idempotent across both schemas.
INSERT INTO public.configurations_paiement (pays, prestataire, mode, devise, est_actif)
SELECT 'benin', 'REVENUECAT', 'sandbox', 'EUR', false
WHERE NOT EXISTS (
  SELECT 1 FROM public.configurations_paiement
  WHERE pays = 'benin' AND prestataire = 'REVENUECAT' AND mode = 'sandbox'
);

COMMIT;
