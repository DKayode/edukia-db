-- Régénération du code de réinitialisation de mot de passe (edukia#243).
--
-- Le parcours « mot de passe oublié » régénérait déjà un code à chaque appel de
-- /auth/forgot-password, mais sans aucune trace de cadence ni d'échecs : rien
-- n'empêchait d'envoyer dix emails d'affilée sur la boîte d'un tiers, ni de
-- brute-forcer un code à 6 chiffres.
--
-- Ces trois compteurs portent l'état d'un « cycle » de réinitialisation, qui
-- démarre au premier envoi et se termine à la réussite, à l'expiration, ou à
-- l'épuisement des envois/tentatives.
--
-- Idempotent : ADD COLUMN IF NOT EXISTS.
BEGIN;

ALTER TABLE public.utilisateurs
    ADD COLUMN IF NOT EXISTS code_dernier_envoi timestamptz NULL,
    ADD COLUMN IF NOT EXISTS code_envois        smallint    NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS code_tentatives    smallint    NOT NULL DEFAULT 0;

COMMENT ON COLUMN public.utilisateurs.code_dernier_envoi IS
    'Horodatage du dernier envoi de code de réinitialisation — sert la cadence de renvoi.';
COMMENT ON COLUMN public.utilisateurs.code_envois IS
    'Nombre d''envois de code sur le cycle de réinitialisation courant.';
COMMENT ON COLUMN public.utilisateurs.code_tentatives IS
    'Nombre de vérifications erronées du code courant.';

COMMIT;
