-- Paiements entrants : modes sandbox/live par prestataire et KKiaPay par defaut.
--
-- Les cles API restent dans l'environnement serveur ou dans
-- configurations_paiement.credentials_chiffres via le back-office. Cette
-- migration cree seulement les lignes de configuration et choisit le
-- prestataire actif par defaut.
BEGIN;

ALTER TABLE public.paiements
    ADD COLUMN IF NOT EXISTS mode varchar(20) NOT NULL DEFAULT 'sandbox';

DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'chk_paiements_mode') THEN
        ALTER TABLE public.paiements ADD CONSTRAINT chk_paiements_mode
            CHECK (mode IN ('sandbox','live'));
    END IF;
END $$;

ALTER TABLE public.configurations_paiement
    ADD COLUMN IF NOT EXISTS mode varchar(20) NOT NULL DEFAULT 'sandbox';

WITH doublons AS (
    SELECT
        id,
        ROW_NUMBER() OVER (
            PARTITION BY pays, prestataire, mode
            ORDER BY est_actif DESC, date_modification DESC, id DESC
        ) AS rang
    FROM public.configurations_paiement
)
DELETE FROM public.configurations_paiement c
USING doublons d
WHERE c.id = d.id
  AND d.rang > 1;

CREATE UNIQUE INDEX IF NOT EXISTS uq_config_paiement_pays_prestataire_mode
    ON public.configurations_paiement(pays, prestataire, mode);

INSERT INTO public.configurations_paiement (pays, prestataire, mode, devise, est_actif)
VALUES
    ('benin', 'KKIAPAY', 'sandbox', 'XOF', false),
    ('benin', 'KKIAPAY', 'live', 'XOF', false),
    ('benin', 'FEDAPAY', 'sandbox', 'XOF', false),
    ('benin', 'FEDAPAY', 'live', 'XOF', false)
ON CONFLICT (pays, prestataire, mode) DO NOTHING;

-- Un seul prestataire actif par pays : KKiaPay sandbox est le defaut de test.
UPDATE public.configurations_paiement
   SET est_actif = false,
       date_modification = now()
 WHERE pays = 'benin'
   AND est_actif = true;

UPDATE public.configurations_paiement
   SET est_actif = true,
       date_modification = now()
 WHERE pays = 'benin'
   AND prestataire = 'KKIAPAY'
   AND mode = 'sandbox';

COMMIT;
