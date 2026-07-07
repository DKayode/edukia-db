-- Ville — country-scoped geo entity nested under a département (031 depends
-- on 030). Cascade: pays → département → ville.
--   * id: UUID PK (matches the departements UUID decision).
--   * departement_id: uuid NOT NULL, ON DELETE CASCADE — a ville cannot exist
--     without its département; removing a département removes its villes.
--   * pays: carried on the row too (denormalised) so villes can be filtered
--     by @CurrentCountry without a join.
--
-- Unique (nom, departement_id): a ville name is unique within its département.
--
-- Idempotent: CREATE TABLE / FK guarded by pg_constraint check / unique index
-- guarded by IF NOT EXISTS.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.villes (
    id             uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    nom            varchar(255) NOT NULL,
    departement_id uuid         NOT NULL,
    pays           varchar(50)  NOT NULL DEFAULT 'benin',
    date_creation  timestamptz  NOT NULL DEFAULT now()
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_villes_departement'
    ) THEN
        ALTER TABLE public.villes
            ADD CONSTRAINT fk_villes_departement
            FOREIGN KEY (departement_id) REFERENCES public.departements(id)
            ON DELETE CASCADE;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS uq_villes_nom_departement
    ON public.villes(nom, departement_id);

CREATE INDEX IF NOT EXISTS idx_villes_departement_id
    ON public.villes(departement_id);

CREATE INDEX IF NOT EXISTS idx_villes_pays
    ON public.villes(pays);

COMMIT;
