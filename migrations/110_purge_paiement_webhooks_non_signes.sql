-- 110 — Purge des webhooks de paiement reçus sans signature valide (edukia#311)
--
-- Jusqu'ici le backend écrivait la ligne de `paiement_webhooks` AVANT de
-- vérifier la signature, et l'index unique (prestataire, evenement_id) servait
-- de dédoublonnage. N'importe qui pouvait donc poster un corps non signé avec
-- un identifiant d'évènement donné : le vrai évènement, signé, arrivé ensuite
-- tombait en « doublon » et n'était jamais traité. Les identifiants FedaPay
-- sont séquentiels, donc devinables.
--
-- Le backend ne persiste plus que les évènements authentifiés. Reste à retirer
-- les lignes non signées déjà présentes : chacune réserve encore un identifiant
-- que le prestataire peut légitimement envoyer plus tard. Elles n'ont aucune
-- valeur métier — jamais traitées, par construction — et leur contenu de
-- diagnostic est désormais journalisé côté application.
--
-- Idempotent : rejouer la migration ne supprime rien de plus.

BEGIN;

DELETE FROM public.paiement_webhooks
 WHERE signature_valide = false;

COMMIT;
