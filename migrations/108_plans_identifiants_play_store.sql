-- 108 — Ajouter les identifiants produit du Play Store aux plans
--
-- Le webhook RevenueCat porte un `product_id` différent selon le store :
--
--     App Store   com.edukia.app.premium.mensuel
--     Play Store  edukia_premium:mensuel
--     App Store   com.edukia.app.premium.annuel
--     Play Store  edukia_premium:annuel-12m
--
-- La 106 n'avait semé que la forme App Store. Résultat mesuré : les achats
-- Play Store arrivaient bien (35 webhooks reçus), mais `creerPaiementAchatInApp`
-- ne trouvait aucun plan pour « edukia_premium:mensuel » et jetait la
-- notification. L'abonnement restait EN_ATTENTE alors que Google considérait la
-- personne comme abonnée.
--
-- On AJOUTE, on ne remplace pas : un plan porte un identifiant PAR store, et
-- retirer la forme App Store casserait iOS. Le déclencheur d'unicité de la 106
-- vérifie qu'aucun de ces identifiants n'est déjà rattaché à un autre plan.
--
-- Le suffixe Play n'est pas déductible du code (« annuel-12m » ≠ « annuel ») :
-- il est repris tel quel des payloads réellement reçus en production.

BEGIN;

-- Idempotent : on n'ajoute l'identifiant Play que s'il n'y est pas déjà, pour
-- que rejouer la migration ne le duplique pas.
UPDATE public.plans_abonnement
   SET identifiants_store = identifiants_store || ARRAY['edukia_premium:mensuel']
 WHERE code = 'MENSUEL'
   AND NOT (identifiants_store @> ARRAY['edukia_premium:mensuel']);

UPDATE public.plans_abonnement
   SET identifiants_store = identifiants_store || ARRAY['edukia_premium:annuel-12m']
 WHERE code = 'ANNUEL'
   AND NOT (identifiants_store @> ARRAY['edukia_premium:annuel-12m']);

-- TRIMESTRIEL n'a aucun produit Play/App observé dans les webhooks : on ne lui
-- invente pas d'identifiant. À renseigner depuis le back-office le jour où un
-- produit trimestriel existe côté store.

COMMIT;
