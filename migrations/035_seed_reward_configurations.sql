-- Seed des configurations spécifiques par type de contenu.
-- EPREUVE, EXAMEN et CONCOURS reprennent l’ancien payment_configurations.reward_per_exam pour conserver le comportement en production.

WITH active_config AS (
  SELECT reward_per_exam, currency, review_delay_hours, reward_enabled
  FROM payment_configurations
  WHERE is_active = TRUE
  ORDER BY created_at DESC
  LIMIT 1
),
epreuve_type AS (
  SELECT id FROM payment_reward_source_types WHERE code = 'EPREUVE' LIMIT 1
),
examen_type AS (
  SELECT id FROM payment_reward_source_types WHERE code = 'EXAMEN' LIMIT 1
)
INSERT INTO payment_reward_configurations (
  reward_source_type_id,
  reward_source_type_code,
  reward_amount,
  currency,
  reward_enabled,
  review_delay_hours,
  requires_admin_validation,
  daily_reward_amount_limit,
  monthly_reward_amount_limit,
  max_rewards_per_user_per_day,
  max_rewards_per_user_per_month,
  metadata,
  is_active
)
SELECT
  epreuve_type.id,
  'EPREUVE',
  COALESCE(active_config.reward_per_exam, 100),
  COALESCE(active_config.currency, 'XOF'),
  COALESCE(active_config.reward_enabled, TRUE),
  COALESCE(active_config.review_delay_hours, 0),
  FALSE,
  0,
  0,
  0,
  0,
  '{"seededFrom":"payment_configurations.reward_per_exam"}'::jsonb,
  TRUE
FROM epreuve_type
LEFT JOIN active_config ON TRUE
ON CONFLICT (reward_source_type_code) DO NOTHING;

WITH active_config AS (
  SELECT reward_per_exam, currency, review_delay_hours, reward_enabled
  FROM payment_configurations
  WHERE is_active = TRUE
  ORDER BY created_at DESC
  LIMIT 1
),
examen_type AS (
  SELECT id FROM payment_reward_source_types WHERE code = 'EXAMEN' LIMIT 1
)
INSERT INTO payment_reward_configurations (
  reward_source_type_id,
  reward_source_type_code,
  reward_amount,
  currency,
  reward_enabled,
  review_delay_hours,
  requires_admin_validation,
  daily_reward_amount_limit,
  monthly_reward_amount_limit,
  max_rewards_per_user_per_day,
  max_rewards_per_user_per_month,
  metadata,
  is_active
)
SELECT
  examen_type.id,
  'EXAMEN',
  COALESCE(active_config.reward_per_exam, 100),
  COALESCE(active_config.currency, 'XOF'),
  COALESCE(active_config.reward_enabled, TRUE),
  COALESCE(active_config.review_delay_hours, 0),
  FALSE,
  0,
  0,
  0,
  0,
  '{"seededFrom":"payment_configurations.reward_per_exam","note":"À ajuster côté admin selon les règles examens."}'::jsonb,
  TRUE
FROM examen_type
LEFT JOIN active_config ON TRUE
ON CONFLICT (reward_source_type_code) DO NOTHING;

WITH active_config AS (
  SELECT reward_per_exam, currency, review_delay_hours, reward_enabled
  FROM payment_configurations
  WHERE is_active = TRUE
  ORDER BY created_at DESC
  LIMIT 1
),
concours_type AS (
  SELECT id FROM payment_reward_source_types WHERE code = 'CONCOURS' LIMIT 1
)
INSERT INTO payment_reward_configurations (
  reward_source_type_id,
  reward_source_type_code,
  reward_amount,
  currency,
  reward_enabled,
  review_delay_hours,
  requires_admin_validation,
  daily_reward_amount_limit,
  monthly_reward_amount_limit,
  max_rewards_per_user_per_day,
  max_rewards_per_user_per_month,
  metadata,
  is_active
)
SELECT
  concours_type.id,
  'CONCOURS',
  COALESCE(active_config.reward_per_exam, 100),
  COALESCE(active_config.currency, 'XOF'),
  COALESCE(active_config.reward_enabled, TRUE),
  COALESCE(active_config.review_delay_hours, 0),
  FALSE,
  0,
  0,
  0,
  0,
  '{"seededFrom":"payment_configurations.reward_per_exam","note":"À ajuster côté admin selon les règles concours."}'::jsonb,
  TRUE
FROM concours_type
LEFT JOIN active_config ON TRUE
ON CONFLICT (reward_source_type_code) DO NOTHING;
