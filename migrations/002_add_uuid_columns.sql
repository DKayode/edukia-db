-- Adds external-identifier `uuid` columns to business tables.
-- DEFAULT gen_random_uuid() is volatile, so existing rows are populated
-- row-by-row during ALTER (PostgreSQL rewrites the table). Idempotent: safe
-- to re-run per country.

BEGIN;

ALTER TABLE public.categories     ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.competences    ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.concours       ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.epreuves       ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.etablissements ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.evenements     ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.forums         ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.offres         ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.opportunites   ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.parcours       ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.prestataires   ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.publicites     ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.ressources     ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.services       ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.types          ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();

CREATE UNIQUE INDEX IF NOT EXISTS categories_uuid_key     ON public.categories(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS competences_uuid_key    ON public.competences(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS concours_uuid_key       ON public.concours(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS epreuves_uuid_key       ON public.epreuves(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS etablissements_uuid_key ON public.etablissements(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS evenements_uuid_key     ON public.evenements(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS forums_uuid_key         ON public.forums(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS offres_uuid_key         ON public.offres(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS opportunites_uuid_key   ON public.opportunites(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS parcours_uuid_key       ON public.parcours(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS prestataires_uuid_key   ON public.prestataires(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS publicites_uuid_key     ON public.publicites(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS ressources_uuid_key     ON public.ressources(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS services_uuid_key       ON public.services(uuid);
CREATE UNIQUE INDEX IF NOT EXISTS types_uuid_key          ON public.types(uuid);

COMMIT;
