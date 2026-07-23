-- Separate wallet reward for validated concours (distinct from épreuves).
-- Default 100 (same as reward_per_exam) so existing behavior is unchanged until set.
ALTER TABLE payment_configurations
  ADD COLUMN IF NOT EXISTS reward_per_concours numeric(14,2) NOT NULL DEFAULT 100;
