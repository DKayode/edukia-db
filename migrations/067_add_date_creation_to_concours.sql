-- 067: The concours table had no creation timestamp, so the admin list could
-- not show when each concours was added. Add date_creation (matches the
-- concours_submissions / utilisateurs convention). Additive + idempotent.
-- No pre-existing signal to backfill from: `annee` is the exam year, not the
-- row's creation date, so existing rows fall back to the column default (now()).
ALTER TABLE public.concours
  ADD COLUMN IF NOT EXISTS date_creation timestamptz NOT NULL DEFAULT now();
