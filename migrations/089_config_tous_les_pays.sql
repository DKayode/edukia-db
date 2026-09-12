-- 089 — Donner à chaque pays sa ligne de configuration
--
-- Les migrations 079 (quotas) et 082 (complétion du profil) n'ont semé qu'une
-- ligne, pour le Bénin. L'application en sert trois : benin, senegal, congo.
--
-- Deux conséquences, l'une gênante et l'autre grave.
--
-- GÊNANTE — régler le seuil de complétion pour le Sénégal renvoyait
-- « Configuration de profil introuvable pour ce pays » : la lecture se repliait
-- sur les valeurs par défaut, la page s'affichait donc normalement, mais
-- l'écriture exigeait une ligne existante.
--
-- GRAVE — `QuotaService.reglage()` repliait sur `estActif: true` quand aucune
-- ligne n'existait. Sans effet tant que le verrou d'abonnement était éteint ;
-- depuis son activation, les utilisateurs du Sénégal et du Congo étaient
-- réellement plafonnés, et aucun administrateur ne pouvait le voir ni le
-- changer puisque la page ne liste que les lignes présentes. Constaté en
-- production : Ketsia limitée à 1/mois dans ces deux pays, illimitée au Bénin.
--
-- Les lignes sont semées DÉSACTIVÉES, comme celles du Bénin l'avaient été : un
-- plafond qui n'a jamais été décidé ne doit pas s'appliquer. Cette migration ne
-- change donc rien pour le Bénin, et lève le plafonnement subi ailleurs.

BEGIN;

INSERT INTO public.configurations_profil (pays, seuil_completion, est_actif)
SELECT p.pays, 95, false
  FROM (VALUES ('senegal'), ('congo')) AS p(pays)
 WHERE NOT EXISTS (
        SELECT 1 FROM public.configurations_profil c WHERE c.pays = p.pays
      );

INSERT INTO public.configurations_quota (pays, feature, limite, periode_reset, est_actif)
SELECT p.pays, f.feature, f.limite, 'MENSUEL', false
  FROM (VALUES ('senegal'), ('congo')) AS p(pays)
 CROSS JOIN (VALUES ('RESOURCE_VIEW', 5), ('KETSIA_AI', 1)) AS f(feature, limite)
 WHERE NOT EXISTS (
        SELECT 1 FROM public.configurations_quota c
         WHERE c.pays = p.pays AND c.feature = f.feature
      );

COMMIT;
