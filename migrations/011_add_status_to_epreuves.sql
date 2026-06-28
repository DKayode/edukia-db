-- Add an approval `status` to epreuves (mirrors the services/offres approval
-- workflow). An épreuve uploaded by a regular user lands `pending_approval` and
-- only becomes visible to non-admins once an admin approves it; admins can also
-- decline it.
--
-- status — varchar(20), NOT NULL. Value space mirrors ServiceStatusEnum
--          (pending_approval | declined | approved | active | inactive); épreuves
--          only ever use pending_approval / approved / declined.
--          DEFAULT 'approved' so existing rows AND épreuves created directly by
--          an admin (the dashboard flow) are visible immediately; the upload
--          endpoint sets 'pending_approval' explicitly.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS + CREATE INDEX IF NOT EXISTS, safe to re-run.

BEGIN;

ALTER TABLE public.epreuves ADD COLUMN IF NOT EXISTS status varchar(20) NOT NULL DEFAULT 'approved';

CREATE INDEX IF NOT EXISTS idx_epreuves_status ON public.epreuves(status);

COMMIT;
