CREATE TABLE IF NOT EXISTS withdrawal_otps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  withdrawal_request_id UUID NOT NULL REFERENCES withdrawal_requests(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL,
  phone_number VARCHAR(30) NOT NULL,
  code_hash VARCHAR(128) NOT NULL,
  debug_code VARCHAR(12) NULL,
  expires_at TIMESTAMP NOT NULL,
  consumed_at TIMESTAMP NULL,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  max_attempts INTEGER NOT NULL DEFAULT 3,
  status VARCHAR(30) NOT NULL DEFAULT 'SENT',
  provider VARCHAR(50) NOT NULL DEFAULT 'console',
  provider_message_id VARCHAR(120) NULL,
  failure_reason TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_withdrawal_status ON withdrawal_otps(withdrawal_request_id, status);
CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_user_created_at ON withdrawal_otps(user_id, created_at DESC);
