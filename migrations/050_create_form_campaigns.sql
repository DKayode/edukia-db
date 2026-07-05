-- Form campaign — an admin-built satisfaction survey served to the mobile app.
--   pays → 1..N campaigns → sections (051) → questions (052).
--   Responses (053) + answers (054) hang off a campaign.
--
-- Country-scoped via a `pays varchar(50)` column (default 'benin'), filtered
-- through @CurrentCountry. PK is a UUID (`id uuid DEFAULT gen_random_uuid()`),
-- exposed as the JSON key `uuid` — mirrors the departements/villes decision.
--
-- statut: draft | active | archived. The mobile client shows the ACTIVE
-- campaign on app-open, once per user until answered.
-- trigger_type defaults to 'app_open' (kept as a column for future trigger
-- flexibility; no other values this round).
--
-- Idempotent: CREATE TABLE / CHECK constraints / indexes guarded.

BEGIN;

-- gen_random_uuid() is core on Neon pg15, but require pgcrypto defensively.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.form_campaigns (
    id            uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    titre         varchar(255) NOT NULL,
    description   text         NULL,
    statut        varchar(20)  NOT NULL DEFAULT 'draft'
                  CHECK (statut IN ('draft', 'active', 'archived')),
    trigger_type  varchar(30)  NOT NULL DEFAULT 'app_open',
    date_debut    timestamptz  NULL,
    date_fin      timestamptz  NULL,
    pays          varchar(50)  NOT NULL DEFAULT 'benin',
    created_by    integer      NULL,
    date_creation timestamptz  NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_form_campaigns_pays
    ON public.form_campaigns(pays);

CREATE INDEX IF NOT EXISTS idx_form_campaigns_pays_statut
    ON public.form_campaigns(pays, statut);

COMMIT;
