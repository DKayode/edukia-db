-- Approval workflow + uploader attribution for concours.
--
-- status        — approval state of the concours row. varchar(20), NOT NULL,
--                 DEFAULT 'approved'. Existing rows (and admin-created ones)
--                 stay 'approved' via the default; user-submitted concours are
--                 created 'pending_approval' by the app. Mirrors the services /
--                 offres approval pattern (values from ServiceStatusEnum:
--                 pending_approval | declined | approved | active | inactive).
--                 A CHECK constraint pins the concours-relevant subset.
-- soumis_par_id — the utilisateur who submitted the concours (uploader), so the
--                 approve/decline email knows who to notify. int, NULLABLE
--                 (existing + admin-created rows have no submitter), FK to
--                 utilisateurs ON DELETE SET NULL so deleting a user keeps the
--                 concours alive.
--
-- Indexes: status (status-filtered reads) and (structure_id, titre_id) for the
-- /v1/concours group-by which groups on that pair.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS + guarded constraints + CREATE INDEX
-- IF NOT EXISTS, safe to re-run. BEGIN;…COMMIT;.

BEGIN;

ALTER TABLE public.concours ADD COLUMN IF NOT EXISTS status        varchar(20) NOT NULL DEFAULT 'approved';
ALTER TABLE public.concours ADD COLUMN IF NOT EXISTS soumis_par_id int         NULL;

-- status CHECK + soumis_par_id FK, guarded (no IF NOT EXISTS for ADD CONSTRAINT).
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'concours_status_check'
    ) THEN
        ALTER TABLE public.concours
            ADD CONSTRAINT concours_status_check
            CHECK (status IN ('pending_approval','declined','approved','active','inactive'));
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_concours_soumis_par'
    ) THEN
        ALTER TABLE public.concours
            ADD CONSTRAINT fk_concours_soumis_par
            FOREIGN KEY (soumis_par_id) REFERENCES public.utilisateurs(id)
            ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_concours_status            ON public.concours(status);
CREATE INDEX IF NOT EXISTS idx_concours_structure_titre   ON public.concours(structure_id, titre_id);

COMMIT;
