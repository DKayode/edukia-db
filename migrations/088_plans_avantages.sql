-- 088 — Décrire ce qu'un abonnement apporte
--
-- `plans_abonnement.description` dit la durée — « Accès illimité pendant
-- 1 mois » — pas ce qu'on y gagne. Au moment de payer, l'utilisateur a besoin
-- de lire ce que l'abonnement débloque, ressource par ressource.
--
-- Une liste plutôt qu'un texte libre : l'application mobile peut ainsi
-- l'afficher en puces sans découper une phrase, et l'administration ajoute ou
-- retire une ligne sans réécrire l'ensemble.

BEGIN;

ALTER TABLE public.plans_abonnement
    ADD COLUMN IF NOT EXISTS avantages text[] NULL;

COMMENT ON COLUMN public.plans_abonnement.avantages IS
    'Ce que l''abonnement débloque, une ligne par avantage. NULL ou vide : rien à afficher.';

-- Valeurs de départ, fidèles à ce que le code accorde RÉELLEMENT : les
-- ressources académiques passent en illimité, les concours s'ouvrent, Ketsia
-- cesse d'être plafonnée. Rien d'autre.
--
-- En particulier, pas de « sans publicité » : le module publicités ignore
-- totalement l'abonnement, un abonné voit donc les mêmes annonces. L'écrire
-- serait vendre ce qui n'existe pas.
--
-- Les plafonds gratuits ne sont volontairement PAS cités : ils se règlent
-- depuis le back-office, et une phrase « au lieu de 5 par mois » deviendrait
-- fausse à la première modification sans que rien ne le signale.
--
-- Seuls les plans qui n'ont rien sont remplis : une formulation déjà retouchée
-- par l'administration ne doit pas être écrasée.
UPDATE public.plans_abonnement
   SET avantages = ARRAY[
        'Épreuves en illimité',
        'Examens nationaux en illimité',
        'Concours : téléchargement des sujets',
        'Ketsia, l''assistante IA, sans limite'
       ]
 WHERE avantages IS NULL OR cardinality(avantages) = 0;

COMMIT;
