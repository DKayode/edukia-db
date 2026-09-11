-- 087 — Rendre le verrou des abonnements réglable depuis le back-office
--
-- `ABONNEMENTS_VERROU_ACTIF` vivait uniquement dans l'environnement : l'éteindre
-- demandait une PR et un redéploiement. C'est pourtant le seul interrupteur qui
-- refuse réellement un accès — les trois autres (plans, quotas, seuil de profil)
-- se règlent en deux clics. Un interrupteur d'urgence qui exige un déploiement
-- n'en est pas un.
--
-- AUCUNE LIGNE N'EST SEMÉE, volontairement. Tant que la table est vide, le
-- serveur retombe sur la variable d'environnement : la migration ne change donc
-- l'état de personne, où qu'elle soit appliquée. La première bascule depuis le
-- back-office crée la ligne, qui fait autorité à partir de là.

BEGIN;

CREATE TABLE IF NOT EXISTS public.configurations_abonnement (
    id                serial PRIMARY KEY,
    uuid              uuid UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays              varchar(50) NOT NULL DEFAULT 'benin',
    verrou_actif      boolean NOT NULL,
    -- Qui a basculé, et quand. Un interrupteur qui coupe le service pour tout
    -- le monde mérite qu'on puisse dire qui l'a actionné.
    modifie_par       integer NULL,
    date_creation     timestamptz NOT NULL DEFAULT now(),
    date_modification timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_configurations_abonnement_pays
    ON public.configurations_abonnement (pays);

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_config_abonnement_modifie_par') THEN
        ALTER TABLE public.configurations_abonnement
            ADD CONSTRAINT fk_config_abonnement_modifie_par
            FOREIGN KEY (modifie_par) REFERENCES public.utilisateurs(id) ON DELETE SET NULL;
    END IF;
END $$;

COMMENT ON TABLE public.configurations_abonnement IS
    'Verrou d''accès par pays. Table vide = on retombe sur ABONNEMENTS_VERROU_ACTIF.';
COMMENT ON COLUMN public.configurations_abonnement.verrou_actif IS
    'true : les refus (quota épuisé, abonnement requis, profil incomplet) s''appliquent. '
    'false : ils sont seulement journalisés et la ressource est servie.';

COMMIT;
