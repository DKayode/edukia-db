-- 088 — Distinguer « pas de handicap » de « question non posée »
--
-- `situation_handicap` portait DEFAULT false : toute inscription écrivait
-- `false`, et plus aucune ligne n'était NULL. Impossible, dès lors, de savoir
-- si la personne a répondu « non » ou n'a jamais vu la question — et compter ce
-- champ dans la complétion du profil (edukia#259) revenait à créditer tout le
-- monde d'un point acquis d'avance.
--
-- On retire la valeur par défaut. Les nouvelles inscriptions laissent donc le
-- champ NULL tant que la question n'a pas été posée, et un « non » explicite
-- reste une réponse qui compte.
--
-- LES LIGNES EXISTANTES NE SONT PAS TOUCHÉES. Les passer à NULL ferait chuter
-- d'un coup la complétion de 32 858 comptes pour une question qu'ils n'ont
-- peut-être jamais vue — un effet de bord bien plus lourd que le point gratuit
-- qu'on cherche à corriger. Elles restent donc `false`, c'est-à-dire comptées
-- comme répondues.

BEGIN;

ALTER TABLE public.utilisateurs
    ALTER COLUMN situation_handicap DROP DEFAULT;

COMMENT ON COLUMN public.utilisateurs.situation_handicap IS
    'Situation de handicap. NULL = question non posée ; false = répondu non ; '
    'true = répondu oui. Comptée dans la complétion du profil dès qu''elle n''est pas NULL.';

COMMIT;
