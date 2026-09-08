-- Seuil de complétion du profil (edukia#259).
--
-- Bloquer les ressources académiques et Ketsia pour les profils incomplets.
--
-- ⚠️ SEMÉ DÉSACTIVÉ, et ce n'est pas une précaution de principe : mesuré sur la
-- base de développement (26 450 comptes, copie de production), AUCUN compte
-- n'atteint 95 %. Le maximum observé est 76 %, sur un seul compte ; 96 % des
-- comptes sont entre 29 et 35 %. Activer le seuil à la livraison couperait
-- l'accès à la totalité des utilisateurs, abonnés compris.
--
-- Le seuil est donc réglable depuis le back-office, comme les quotas (#245) et
-- le taux de commission (#246) : le chiffre est un arbitrage produit, il n'a
-- rien à faire dans le code.
--
-- Rien n'est stocké par compte : la complétion se calcule à la volée depuis
-- `utilisateurs`.
--
-- Idempotent : CREATE TABLE/INDEX IF NOT EXISTS, contraintes gardées.
BEGIN;

CREATE TABLE IF NOT EXISTS public.configurations_profil (
    id                serial      PRIMARY KEY,
    uuid              uuid        UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays              varchar(50) NOT NULL DEFAULT 'benin',
    -- Pourcentage exigé pour accéder aux ressources académiques et à Ketsia.
    seuil_completion  int         NOT NULL DEFAULT 95,
    est_actif         boolean     NOT NULL DEFAULT false,
    -- Retirer un champ du calcul sans redéployer — par exemple si un champ
    -- cesse d'être demandé dans l'application.
    champs_exclus     varchar(50)[] NULL,
    date_creation     timestamptz NOT NULL DEFAULT now(),
    date_modification timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_configurations_profil_pays
    ON public.configurations_profil(pays);

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_config_profil_seuil') THEN
        ALTER TABLE public.configurations_profil ADD CONSTRAINT chk_config_profil_seuil
            CHECK (seuil_completion >= 0 AND seuil_completion <= 100);
    END IF;
END $$;

COMMENT ON COLUMN public.configurations_profil.seuil_completion IS
    'Pourcentage de complétion exigé. Avec 16 champs comptés, 95 % équivaut à 100 % : 15/16 vaut 93,75 % et il n''existe aucune valeur intermédiaire.';

INSERT INTO public.configurations_profil (pays, seuil_completion, est_actif)
VALUES ('benin', 95, false)
ON CONFLICT (pays) DO NOTHING;

COMMIT;
