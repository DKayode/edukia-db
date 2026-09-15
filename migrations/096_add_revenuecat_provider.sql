-- Ajouter RevenueCat comme prestataire d'abonnements in-app.
-- L'achat est effectué par le SDK mobile ; le backend reçoit les webhooks.

BEGIN;

INSERT INTO public.configurations_paiement (pays, prestataire, mode, devise, est_actif)
VALUES ('benin', 'REVENUECAT', 'sandbox', 'EUR', false)
ON CONFLICT (pays, prestataire, mode) DO NOTHING;

COMMIT;
