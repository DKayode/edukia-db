-- Concours user-submission workflow (v2): a SEPARATE submission table instead
-- of an approval status on the concours table itself.
--
-- This migration REPLACES the earlier v1 approach (which added `status` and
-- `soumis_par_id` columns to `concours`). It therefore:
--   (a) DROPs those v1 columns (+ their constraint / FK / status index) — the
--       real `concours` table goes back to clean, unfiltered reads.
--       idx_concours_structure_titre is KEPT: the /v1/concours group-by still
--       groups on (structure_id, titre_id).
--   (b) CREATEs `concours_submissions` — a pending queue where any user submits
--       a concours, possibly naming a structure/titre that doesn't exist yet
--       (proposed_structure / proposed_titre). The admin resolves the missing
--       parents and, on approval, a real `concours` row is created.
--
-- Idempotent: DROP ... IF EXISTS + CREATE TABLE/INDEX IF NOT EXISTS, guarded
-- constraint. Safe to re-run. BEGIN;…COMMIT;.

BEGIN;

-- (a) Undo the v1 status-column approach on concours -------------------------
ALTER TABLE public.concours DROP CONSTRAINT IF EXISTS concours_status_check;
ALTER TABLE public.concours DROP CONSTRAINT IF EXISTS fk_concours_soumis_par;
DROP INDEX IF EXISTS public.idx_concours_status;
ALTER TABLE public.concours DROP COLUMN IF EXISTS status;
ALTER TABLE public.concours DROP COLUMN IF EXISTS soumis_par_id;
-- idx_concours_structure_titre is intentionally retained (group-by support).

-- (b) Submission queue -------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.concours_submissions (
    id                 serial       PRIMARY KEY,
    uuid               uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays               varchar(50)  NOT NULL DEFAULT 'benin',
    -- Either an existing reference id OR a free-text proposed name (admin
    -- resolves the proposed ones into real structure/titre rows at approval).
    structure_id       int          NULL,
    proposed_structure text         NULL,
    titre_id           int          NULL,
    proposed_titre     text         NULL,
    annee              int          NULL,
    lieu               text         NULL,
    -- File columns mirror concours: R2 path/ext + legacy Firebase url.
    file_path          text         NOT NULL DEFAULT '',
    file_extension     varchar(10)  NOT NULL DEFAULT '',
    url                text         NOT NULL DEFAULT '',
    soumis_par_id      int          NULL,
    status             varchar(20)  NOT NULL DEFAULT 'pending_approval',
    date_creation      timestamptz  NOT NULL DEFAULT now()
);

-- FK to utilisateurs (guarded; no IF NOT EXISTS for ADD CONSTRAINT).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_concours_submissions_soumis_par'
    ) THEN
        ALTER TABLE public.concours_submissions
            ADD CONSTRAINT fk_concours_submissions_soumis_par
            FOREIGN KEY (soumis_par_id) REFERENCES public.utilisateurs(id)
            ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_concours_submissions_status ON public.concours_submissions(status);
CREATE INDEX IF NOT EXISTS idx_concours_submissions_pays   ON public.concours_submissions(pays);

COMMIT;
