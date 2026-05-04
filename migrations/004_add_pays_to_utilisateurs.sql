-- Add pays to utilisateurs.
--
-- Auth still works cross-country (login is not pays-scoped), but stats and
-- the admin user list group/filter by signup country. Existing rows backfill
-- to 'benin'; new rows get the country picked by the client at signup time
-- and validated by the backend middleware against config.json.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS, safe to re-run per environment.

BEGIN;

ALTER TABLE public.utilisateurs ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';

CREATE INDEX IF NOT EXISTS idx_utilisateurs_pays ON public.utilisateurs(pays);

COMMIT;
