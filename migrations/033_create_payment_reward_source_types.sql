CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS payment_reward_source_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(50) NOT NULL UNIQUE,
  label VARCHAR(100) NOT NULL,
  description TEXT NULL,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

INSERT INTO payment_reward_source_types (code, label, description, is_active)
VALUES
  ('EPREUVE', 'Épreuve chargée', 'Crédit accordé après validation d’une épreuve chargée par l’utilisateur.', TRUE),
  ('EXAMEN', 'Examen national chargé', 'Crédit accordé après validation d’un examen national ou assimilé.', TRUE),
  ('CONCOURS', 'Concours chargé', 'Crédit accordé après validation d’un concours chargé par l’utilisateur.', TRUE)
ON CONFLICT (code) DO UPDATE SET
  label = EXCLUDED.label,
  description = EXCLUDED.description,
  is_active = TRUE,
  updated_at = NOW();
