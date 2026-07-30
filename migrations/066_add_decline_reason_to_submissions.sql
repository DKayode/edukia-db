-- Persist the admin's explanation when an épreuve/concours submission is declined
-- (previously the reason was only logged). Shown back to the submitter.
ALTER TABLE epreuve_submissions
  ADD COLUMN IF NOT EXISTS decline_reason TEXT;

ALTER TABLE concours_submissions
  ADD COLUMN IF NOT EXISTS decline_reason TEXT;
