CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS payment_reward_configurations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reward_source_type_id UUID NOT NULL REFERENCES payment_reward_source_types(id),
  reward_source_type_code VARCHAR(50) NOT NULL UNIQUE,
  reward_amount NUMERIC(14,2) NOT NULL DEFAULT 100 CHECK (reward_amount >= 0),
  currency VARCHAR(10) NOT NULL DEFAULT 'XOF',
  reward_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  review_delay_hours INTEGER NOT NULL DEFAULT 0 CHECK (review_delay_hours >= 0),
  requires_admin_validation BOOLEAN NOT NULL DEFAULT FALSE,
  daily_reward_amount_limit NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (daily_reward_amount_limit >= 0),
  monthly_reward_amount_limit NUMERIC(14,2) NOT NULL DEFAULT 0 CHECK (monthly_reward_amount_limit >= 0),
  max_rewards_per_user_per_day INTEGER NOT NULL DEFAULT 0 CHECK (max_rewards_per_user_per_day >= 0),
  max_rewards_per_user_per_month INTEGER NOT NULL DEFAULT 0 CHECK (max_rewards_per_user_per_month >= 0),
  metadata JSONB NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  updated_by INTEGER NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_payment_reward_configurations_source_type_id
  ON payment_reward_configurations(reward_source_type_id);
