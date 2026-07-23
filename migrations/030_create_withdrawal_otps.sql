CREATE TABLE IF NOT EXISTS withdrawal_otps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  withdrawal_request_id UUID NOT NULL REFERENCES withdrawal_requests(id) ON DELETE CASCADE,
  user_id INTEGER NOT NULL,
  phone_number VARCHAR(30) NOT NULL,
  code_hash VARCHAR(128) NOT NULL,
  debug_code VARCHAR(12),
  expires_at TIMESTAMP NOT NULL,
  consumed_at TIMESTAMP,
  attempt_count INTEGER NOT NULL DEFAULT 0,
  max_attempts INTEGER NOT NULL DEFAULT 3,
  resend_count INTEGER NOT NULL DEFAULT 0,
  last_sent_at TIMESTAMP,
  status VARCHAR(30) NOT NULL DEFAULT 'SENT' CHECK (status IN ('SENT','VERIFIED','EXPIRED','FAILED','LOCKED')),
  provider VARCHAR(50) NOT NULL DEFAULT 'console',
  provider_message_id VARCHAR(120),
  provider_bulk_id VARCHAR(120),
  failure_reason TEXT,
  delivery_status VARCHAR(40) NOT NULL DEFAULT 'CREATED' CHECK (delivery_status IN ('NOT_REQUIRED','CREATED','SENT_TO_PROVIDER','DELIVERED','UNDELIVERED','FAILED','DELIVERY_UNKNOWN','DELIVERY_TIMEOUT')),
  provider_status_name VARCHAR(120),
  provider_status_group_name VARCHAR(120),
  provider_status_description TEXT,
  delivery_error_code VARCHAR(120),
  delivery_error_message TEXT,
  delivered_at TIMESTAMP,
  failed_at TIMESTAMP,
  last_provider_callback_at TIMESTAMP,
  delivery_check_count INTEGER NOT NULL DEFAULT 0,
  next_delivery_check_at TIMESTAMP,
  locked_at TIMESTAMP,
  locked_reason TEXT,
  unlocked_at TIMESTAMP,
  unlocked_by INTEGER,
  unlock_reason TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_request_status ON withdrawal_otps(withdrawal_request_id, status);
CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_user_created ON withdrawal_otps(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_provider_message_id ON withdrawal_otps(provider_message_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_delivery_check ON withdrawal_otps(delivery_status, next_delivery_check_at);
