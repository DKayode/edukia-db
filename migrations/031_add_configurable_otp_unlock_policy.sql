-- Migration corrective pour les bases déjà créées avant l’ajout du blocage OTP configurable.

ALTER TABLE payment_configurations
  ADD COLUMN IF NOT EXISTS otp_enabled BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS otp_length INTEGER NOT NULL DEFAULT 6,
  ADD COLUMN IF NOT EXISTS otp_ttl_minutes INTEGER NOT NULL DEFAULT 10,
  ADD COLUMN IF NOT EXISTS otp_max_attempts INTEGER NOT NULL DEFAULT 3,
  ADD COLUMN IF NOT EXISTS otp_resend_cooldown_seconds INTEGER NOT NULL DEFAULT 60,
  ADD COLUMN IF NOT EXISTS otp_max_resends INTEGER NOT NULL DEFAULT 2,
  ADD COLUMN IF NOT EXISTS otp_lock_duration_minutes INTEGER NOT NULL DEFAULT 1440,
  ADD COLUMN IF NOT EXISTS otp_require_admin_unlock BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS otp_auto_unlock_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS otp_block_withdrawal_creation BOOLEAN NOT NULL DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS otp_provider VARCHAR(30) NOT NULL DEFAULT 'infobip';

ALTER TABLE withdrawal_requests
  ADD COLUMN IF NOT EXISTS security_status VARCHAR(40) NOT NULL DEFAULT 'NORMAL',
  ADD COLUMN IF NOT EXISTS security_review_reason TEXT NULL,
  ADD COLUMN IF NOT EXISTS security_reviewed_by INTEGER NULL REFERENCES utilisateurs(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS security_reviewed_at TIMESTAMP NULL,
  ADD COLUMN IF NOT EXISTS otp_locked_at TIMESTAMP NULL,
  ADD COLUMN IF NOT EXISTS otp_unlocked_at TIMESTAMP NULL;

ALTER TABLE withdrawal_otps
  ADD COLUMN IF NOT EXISTS resend_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_sent_at TIMESTAMP NULL,
  ADD COLUMN IF NOT EXISTS locked_at TIMESTAMP NULL,
  ADD COLUMN IF NOT EXISTS locked_reason TEXT NULL,
  ADD COLUMN IF NOT EXISTS unlocked_at TIMESTAMP NULL,
  ADD COLUMN IF NOT EXISTS unlocked_by INTEGER NULL REFERENCES utilisateurs(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS unlock_reason TEXT NULL;

-- Les contraintes CHECK existantes sur status peuvent varier selon les environnements.
-- Pour éviter de casser une base existante, les ALTER DROP CONSTRAINT doivent être adaptés
-- au nom réel de la contrainte si PostgreSQL l’a généré automatiquement.

CREATE INDEX IF NOT EXISTS idx_withdrawal_requests_security_status ON withdrawal_requests(security_status);
CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_locked_at ON withdrawal_otps(locked_at) WHERE locked_at IS NOT NULL;
