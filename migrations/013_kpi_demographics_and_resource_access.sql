-- KPI dashboard: demographic fields + resource access log.
--
-- Supports the Mastercard Foundation KPI dashboard (sections Utilisateurs /
-- Apprenants / Engagement). Two changes:
--
-- 1. utilisateurs gains three OPTIONAL, NULLABLE demographic columns. They are
--    sensitive PII captured with consent by the mobile app — never required on
--    signup/update. Existing rows stay NULL and are simply excluded from the
--    demographic KPIs (age ≤ 35, rural zone, disability).
--      - date_naissance     — birth date; age-at-registration = date_creation − date_naissance.
--      - zone_residence     — 'rural' | 'urbain'.
--      - situation_handicap — 'visuel' | 'auditif' | 'moteur' | 'psychomoteur' | 'aucun'.
--    CHECK constraints allow NULL (consent-optional) but constrain non-null values.
--
-- 2. resource_access — append-only log of distinct learner access to a downloadable
--    resource (épreuve | concours), feeding KPI 16 (week / 2-week / month windows).
--    utilisateur_id FK ON DELETE SET NULL so deleting a user keeps the aggregate
--    counts intact. pays mirrors the country-scoping convention.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS / CREATE TABLE IF NOT EXISTS / guarded
-- constraints, safe to re-run. edukia-dev only.

BEGIN;

ALTER TABLE public.utilisateurs ADD COLUMN IF NOT EXISTS date_naissance date NULL;
ALTER TABLE public.utilisateurs ADD COLUMN IF NOT EXISTS zone_residence varchar(20) NULL;
ALTER TABLE public.utilisateurs ADD COLUMN IF NOT EXISTS situation_handicap varchar(20) NULL;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'utilisateurs_zone_residence_check') THEN
    ALTER TABLE public.utilisateurs ADD CONSTRAINT utilisateurs_zone_residence_check
      CHECK (zone_residence IS NULL OR zone_residence IN ('rural','urbain'));
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'utilisateurs_situation_handicap_check') THEN
    ALTER TABLE public.utilisateurs ADD CONSTRAINT utilisateurs_situation_handicap_check
      CHECK (situation_handicap IS NULL OR situation_handicap IN ('visuel','auditif','moteur','psychomoteur','aucun'));
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS public.resource_access (
  id              serial PRIMARY KEY,
  utilisateur_id  int NULL REFERENCES public.utilisateurs(id) ON DELETE SET NULL,
  resource_type   varchar(20) NOT NULL,
  resource_id     int NOT NULL,
  pays            varchar(50) NOT NULL DEFAULT 'benin',
  accessed_at     timestamptz NOT NULL DEFAULT now()
);

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'resource_access_resource_type_check') THEN
    ALTER TABLE public.resource_access ADD CONSTRAINT resource_access_resource_type_check
      CHECK (resource_type IN ('epreuve','concours'));
  END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_resource_access_accessed_at ON public.resource_access(accessed_at);
CREATE INDEX IF NOT EXISTS idx_resource_access_utilisateur_id ON public.resource_access(utilisateur_id);

COMMIT;
