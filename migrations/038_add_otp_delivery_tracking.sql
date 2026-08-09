ALTER TABLE withdrawal_otps
  ADD COLUMN IF NOT EXISTS provider_bulk_id VARCHAR(120),
  ADD COLUMN IF NOT EXISTS delivery_status VARCHAR(40) NOT NULL DEFAULT 'CREATED',
  ADD COLUMN IF NOT EXISTS provider_status_name VARCHAR(120),
  ADD COLUMN IF NOT EXISTS provider_status_group_name VARCHAR(120),
  ADD COLUMN IF NOT EXISTS provider_status_description TEXT,
  ADD COLUMN IF NOT EXISTS delivery_error_code VARCHAR(120),
  ADD COLUMN IF NOT EXISTS delivery_error_message TEXT,
  ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP,
  ADD COLUMN IF NOT EXISTS failed_at TIMESTAMP,
  ADD COLUMN IF NOT EXISTS last_provider_callback_at TIMESTAMP,
  ADD COLUMN IF NOT EXISTS delivery_check_count INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS next_delivery_check_at TIMESTAMP;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_withdrawal_otps_delivery_status'
  ) THEN
    ALTER TABLE withdrawal_otps
      ADD CONSTRAINT chk_withdrawal_otps_delivery_status
      CHECK (delivery_status IN ('NOT_REQUIRED','CREATED','SENT_TO_PROVIDER','DELIVERED','UNDELIVERED','FAILED','DELIVERY_UNKNOWN','DELIVERY_TIMEOUT'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_provider_message_id ON withdrawal_otps(provider_message_id);
CREATE INDEX IF NOT EXISTS idx_withdrawal_otps_delivery_check ON withdrawal_otps(delivery_status, next_delivery_check_at);

-- Valeurs utiles si des OTP existaient avant cette migration.
UPDATE withdrawal_otps
SET delivery_status = CASE
  WHEN provider = 'infobip' AND provider_message_id IS NOT NULL THEN 'SENT_TO_PROVIDER'
  WHEN provider = 'console' THEN 'NOT_REQUIRED'
  WHEN status = 'FAILED' THEN 'FAILED'
  ELSE delivery_status
END
WHERE delivery_status = 'CREATED';
