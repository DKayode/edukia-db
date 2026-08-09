-- Migration additive pour les bases déjà en ligne après introduction de EPREUVE/EXAMEN.
-- Ajoute le type CONCOURS et sa configuration sans toucher aux données existantes.

INSERT INTO payment_reward_source_types (code, label, description, is_active)
VALUES
  ('CONCOURS', 'Concours chargé', 'Crédit accordé après validation d’un concours chargé par l’utilisateur.', TRUE)
ON CONFLICT (code) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  is_active = TRUE,
  updated_at = NOW();

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
  '{"seededFrom":"036_add_concours_reward_configuration","amount":300,"note":"À ajuster côté admin selon les règles concours."}'::jsonb,
  TRUE
FROM concours_type
LEFT JOIN active_config ON TRUE
ON CONFLICT (reward_source_type_code) DO NOTHING;
