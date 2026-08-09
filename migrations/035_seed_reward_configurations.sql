-- Seed des configurations par type de contenu.
--
-- Les montants sont EXPLICITES et volontairement différents par source :
-- épreuve 200, examen national 300, concours 300 (XOF). Ils ne dérivent plus de
-- payment_configurations.reward_per_exam : ce champ ne connaît que les épreuves,
-- si bien que le concours — payé 200 via reward_per_concours — serait retombé à
-- 100 en passant par ici. Les autres réglages (devise, délai de revue,
-- activation) continuent de suivre la configuration globale active.
--
-- ON CONFLICT DO NOTHING : une base déjà seedée garde ses valeurs, elles se
-- règlent ensuite depuis Approbations > Wallet > Configuration.

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
  200,
  COALESCE(active_config.currency, 'XOF'),
  COALESCE(active_config.reward_enabled, TRUE),
  COALESCE(active_config.review_delay_hours, 0),
  FALSE,
  0,
  0,
  0,
  0,
  '{"seededFrom":"035_seed_reward_configurations","amount":200}'::jsonb,
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
  300,
  COALESCE(active_config.currency, 'XOF'),
  COALESCE(active_config.reward_enabled, TRUE),
  COALESCE(active_config.review_delay_hours, 0),
  FALSE,
  0,
  0,
  0,
  0,
  '{"seededFrom":"035_seed_reward_configurations","amount":300,"note":"À ajuster côté admin selon les règles examens."}'::jsonb,
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
  300,
  COALESCE(active_config.currency, 'XOF'),
  COALESCE(active_config.reward_enabled, TRUE),
  COALESCE(active_config.review_delay_hours, 0),
  FALSE,
  0,
  0,
  0,
  0,
  '{"seededFrom":"035_seed_reward_configurations","amount":300,"note":"À ajuster côté admin selon les règles concours."}'::jsonb,
  TRUE
FROM concours_type
LEFT JOIN active_config ON TRUE
ON CONFLICT (reward_source_type_code) DO NOTHING;
