-- REWORKED 011 — user épreuve submissions (2-step flow).
--
-- The earlier 011 added an approval `status` column directly on `epreuves`, but
-- that model can't represent a submission whose PARENT entities (etablissement →
-- filière → niveau → matière) don't exist yet (epreuves.matiere_id is NOT NULL).
-- So user uploads move to a dedicated staging table and the admin resolves any
-- missing parents at approval time. The admin direct-create path on `epreuves`
-- is unchanged.
--
-- Two parts, both idempotent (safe to re-run on edukia-dev):
--   (a) DROP the old epreuves.status column + its index.
--   (b) CREATE epreuve_submissions: for each parent level either an EXISTING id
--       (FK, ON DELETE SET NULL) OR a PROPOSED name (text) when it's new; plus
--       titre/annee/section, the file columns, the uploader, and a status.
--
-- Parent table names verified against the live schema / earlier migrations:
--   etablissements, filieres, niveau_etude, matieres, utilisateurs (all id int).

BEGIN;

-- (a) Remove the previous status-column model (dev-only).
DROP INDEX IF EXISTS idx_epreuves_status;
ALTER TABLE public.epreuves DROP COLUMN IF EXISTS status;

-- (b) Submission staging table.
CREATE TABLE IF NOT EXISTS public.epreuve_submissions (
  id                     serial PRIMARY KEY,
  uuid                   uuid NOT NULL UNIQUE DEFAULT gen_random_uuid(),
  pays                   varchar(50) NOT NULL DEFAULT 'benin',

  etablissement_id       int NULL REFERENCES public.etablissements(id) ON DELETE SET NULL,
  proposed_etablissement text NULL,
  filiere_id             int NULL REFERENCES public.filieres(id) ON DELETE SET NULL,
  proposed_filiere       text NULL,
  niveau_etude_id        int NULL REFERENCES public.niveau_etude(id) ON DELETE SET NULL,
  proposed_niveau        text NULL,
  matiere_id             int NULL REFERENCES public.matieres(id) ON DELETE SET NULL,
  proposed_matiere       text NULL,

  titre                  text NOT NULL,
  annee                  int NULL,
  section                varchar(50) NOT NULL DEFAULT 'normal',

  file_path              text NOT NULL DEFAULT '',
  file_extension         varchar(10) NOT NULL DEFAULT '',
  url                    text NOT NULL DEFAULT '',

  soumis_par_id          int NULL REFERENCES public.utilisateurs(id) ON DELETE SET NULL,
  status                 varchar(20) NOT NULL DEFAULT 'pending_approval',
  date_creation          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_epreuve_submissions_status ON public.epreuve_submissions(status);
CREATE INDEX IF NOT EXISTS idx_epreuve_submissions_soumis_par_id ON public.epreuve_submissions(soumis_par_id);

COMMIT;
