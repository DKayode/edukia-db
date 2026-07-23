-- Département — a country-scoped geo entity sitting directly under `pays`.
--   pays → 1..N départements → 1..N villes (see 031).
-- Admin-curated lookup table (row-by-row + CSV import). Country scoping via a
-- `pays varchar(50)` column, default 'benin', filtered via @CurrentCountry.
--
-- PK is a UUID (`id uuid DEFAULT gen_random_uuid()`), not a serial — product
-- decision: geo ids are opaque uuids exposed as the JSON key `id`.
-- Unique (nom, pays): a département name is unique within a country.
--
-- Idempotent: CREATE TABLE / unique index guarded by IF NOT EXISTS.

BEGIN;

-- gen_random_uuid() is core on Neon pg15, but require pgcrypto defensively.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.departements (
    id            uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    nom           varchar(255) NOT NULL,
    code          varchar(50)  NULL,
    pays          varchar(50)  NOT NULL DEFAULT 'benin',
    date_creation timestamptz  NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_departements_nom_pays
    ON public.departements(nom, pays);

CREATE INDEX IF NOT EXISTS idx_departements_pays
    ON public.departements(pays);

COMMIT;
