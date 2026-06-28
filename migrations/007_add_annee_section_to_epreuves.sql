-- Add annee and section to epreuves.
--
-- annee   — exam year. Integer, NULLABLE (older épreuves may not have it).
-- section — exam session: 'normal' | 'rattrapage' (resit). Required, defaults
--           to 'normal'. Enforced by a CHECK constraint here and IsEnum in the
--           app. Existing rows backfill to 'normal' via the column default.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS + guarded constraint, safe to re-run.

BEGIN;

ALTER TABLE public.epreuves ADD COLUMN IF NOT EXISTS annee int NULL;
ALTER TABLE public.epreuves ADD COLUMN IF NOT EXISTS section varchar(20) NOT NULL DEFAULT 'normal';

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'epreuves_section_check') THEN
    ALTER TABLE public.epreuves ADD CONSTRAINT epreuves_section_check CHECK (section IN ('normal','rattrapage'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_epreuves_section ON public.epreuves(section);

COMMIT;
