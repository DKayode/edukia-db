-- Concours reward default is now 200 (épreuve stays 100).
ALTER TABLE payment_configurations ALTER COLUMN reward_per_concours SET DEFAULT 200;
-- Bring existing configs still on the old default (100) up to the new default.
UPDATE payment_configurations SET reward_per_concours = 200 WHERE reward_per_concours = 100;
