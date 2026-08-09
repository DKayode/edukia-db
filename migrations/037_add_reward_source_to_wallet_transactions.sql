ALTER TABLE wallet_transactions
  ADD COLUMN IF NOT EXISTS reward_source_type_id UUID NULL REFERENCES payment_reward_source_types(id),
  ADD COLUMN IF NOT EXISTS reward_source_type_code VARCHAR(50) NULL,
  ADD COLUMN IF NOT EXISTS reward_source_id VARCHAR(150) NULL,
  ADD COLUMN IF NOT EXISTS reward_source_reference VARCHAR(255) NULL;

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_reward_source
  ON wallet_transactions(wallet_id, reward_source_type_code, reward_source_id);

CREATE INDEX IF NOT EXISTS idx_wallet_transactions_reward_source_type_created_at
  ON wallet_transactions(wallet_id, reward_source_type_code, created_at);

-- Backfill sécurisé : les anciennes transactions REWARD sont considérées comme des crédits d’épreuves.
-- On évite une contrainte unique immédiate pour ne pas casser une base déjà en production avec d'anciennes données.
WITH epreuve_type AS (
  SELECT id FROM payment_reward_source_types WHERE code = 'EPREUVE' LIMIT 1
)
UPDATE wallet_transactions wt
SET
  reward_source_type_id = (SELECT id FROM epreuve_type),
  reward_source_type_code = 'EPREUVE',
  reward_source_id = COALESCE(
    NULLIF(wt.metadata ->> 'examId', ''),
    NULLIF(wt.metadata ->> 'rewardSourceId', ''),
    REGEXP_REPLACE(wt.reference, '^(EXAM_REWARD|EPREUVE_REWARD):', '')
  ),
  reward_source_reference = wt.reference
WHERE wt.type = 'REWARD'
  AND wt.reward_source_type_code IS NULL
  AND EXISTS (SELECT 1 FROM epreuve_type);
