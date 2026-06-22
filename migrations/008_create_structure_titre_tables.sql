-- Two new standalone reference (lookup) entities for concours:
--   * structure — the organizing body / institution that runs a concours
--   * titre     — the post / title a concours recruits for
-- Each is a simple, admin-curated, country-scoped lookup table (mirrors the
-- shape of `categories`: id, uuid, pays, nom, description, timestamps).
--
-- A concours may then REFERENCE one of each via the new nullable FK columns
-- structure_id / titre_id. Both are nullable so existing concours rows stay
-- valid with no backfill; ON DELETE SET NULL keeps a concours alive if its
-- referenced structure/titre is later removed.
--
-- NOTE: concours already has a free-text `titre` varchar column — that is a
-- SEPARATE concept and is left untouched. The new lookup FK is `titre_id`.
--
-- Idempotent: CREATE TABLE / ADD COLUMN IF NOT EXISTS, and the FK constraints
-- are guarded by a pg_constraint existence check so the file is safe to re-run.

BEGIN;

-- ---------------------------------------------------------------------------
-- structure
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.structure (
    id          serial       PRIMARY KEY,
    uuid        uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays        varchar(50)  NOT NULL DEFAULT 'benin',
    nom         varchar(255) NOT NULL,
    description text         NULL,
    created_at  timestamptz  NOT NULL DEFAULT now(),
    updated_at  timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_structure_pays ON public.structure(pays);

-- ---------------------------------------------------------------------------
-- titre
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.titre (
    id          serial       PRIMARY KEY,
    uuid        uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays        varchar(50)  NOT NULL DEFAULT 'benin',
    nom         varchar(255) NOT NULL,
    description text         NULL,
    created_at  timestamptz  NOT NULL DEFAULT now(),
    updated_at  timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_titre_pays ON public.titre(pays);

-- ---------------------------------------------------------------------------
-- concours — nullable FK columns referencing the new lookup tables
-- ---------------------------------------------------------------------------
ALTER TABLE public.concours ADD COLUMN IF NOT EXISTS structure_id int NULL;
ALTER TABLE public.concours ADD COLUMN IF NOT EXISTS titre_id     int NULL;

-- FK constraints, guarded so re-running is safe (ADD CONSTRAINT has no
-- IF NOT EXISTS form in Postgres).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_concours_structure'
    ) THEN
        ALTER TABLE public.concours
            ADD CONSTRAINT fk_concours_structure
            FOREIGN KEY (structure_id) REFERENCES public.structure(id)
            ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_concours_titre'
    ) THEN
        ALTER TABLE public.concours
            ADD CONSTRAINT fk_concours_titre
            FOREIGN KEY (titre_id) REFERENCES public.titre(id)
            ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_concours_structure_id ON public.concours(structure_id);
CREATE INDEX IF NOT EXISTS idx_concours_titre_id     ON public.concours(titre_id);

COMMIT;
