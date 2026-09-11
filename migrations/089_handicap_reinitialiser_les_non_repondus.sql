-- 089 — Remettre à NULL les « non » hérités de la valeur par défaut
--
-- La migration 088 retire le DEFAULT false, mais les lignes déjà écrites
-- gardent ce `false` : les comptes existants conservent un point de complétion
-- qu'ils n'ont jamais gagné, et la question ne leur sera jamais posée puisque
-- le champ paraît rempli.
--
-- On les repasse donc à NULL, pour que chacun réponde pour soi.
--
-- CE QUE ÇA COÛTE, mesuré en production :
--   32 809 comptes perdent un point sur seize — la complétion moyenne passe de
--   30 % à 24 %. Sans effet sur les accès : le seuil de complétion est inactif
--   (configurations_profil.est_actif = false), donc personne n'est refusé pour
--   autant. À rejouer avant d'activer ce seuil, pas après.
--
-- CE QUE ÇA PERD : un « non » sincèrement saisi depuis le formulaire de profil
-- est indiscernable d'un `false` posé par défaut à l'inscription. La remise à
-- NULL efface donc aussi de vraies réponses. C'est le prix de la colonne telle
-- qu'elle a vécu jusqu'ici, et il n'existe aucun moyen de les départager.
--
-- LES « OUI » SONT PRÉSERVÉS : personne ne coche `true` par accident, et 3
-- comptes l'ont fait. Les effacer serait une perte sèche d'information.

BEGIN;

UPDATE public.utilisateurs
   SET situation_handicap = NULL
 WHERE situation_handicap IS FALSE;

COMMIT;
