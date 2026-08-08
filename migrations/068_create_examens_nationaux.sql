-- Examens Nationaux — a new resource, sibling of Épreuves/Concours, that is NOT
-- tied to the school hierarchy (établissement → filière → niveau → matière).
-- Instead it is classified by admin-managed, country-scoped lookups:
--   * types_examen     — BAC, CAP, BEPC, BTS, Licence, …
--   * series           — A, C, D, G2, … (the kind of BAC/exam); scoped to a type
--   * matieres_examen  — Anglais, Mathématiques, Électricité, …; scoped to a type
--   * filieres_examen  — Droit, Économie, Génie Civil, …;        scoped to a type
--
-- An examen_national references type (req) + série (opt) + matière (opt) +
-- filière (opt), plus a required année and an optional section. Matière and
-- filière are INDEPENDENT and BOTH optional, but AT LEAST ONE must be set
-- (e.g. BAC → matière only; Licence → filière + matière). Enforced by a CHECK.
--
-- Like épreuves/concours it supports BOTH an admin-created row and a
-- user-submission → admin-approval queue (examens_nationaux_submissions).
--
-- Idempotent: CREATE TABLE/INDEX IF NOT EXISTS + guarded FK constraints.
BEGIN;

-- ---------------------------------------------------------------------------
-- 1) types_examen (lookup)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.types_examen (
    id            serial       PRIMARY KEY,
    uuid          uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays          varchar(50)  NOT NULL DEFAULT 'benin',
    nom           varchar(255) NOT NULL,
    description   text         NULL,
    date_creation timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_types_examen_pays ON public.types_examen(pays);

-- ---------------------------------------------------------------------------
-- 2) series (lookup, scoped to a type)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.series (
    id              serial       PRIMARY KEY,
    uuid            uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays            varchar(50)  NOT NULL DEFAULT 'benin',
    type_examen_id  int          NOT NULL,
    nom             varchar(255) NOT NULL,
    description     text         NULL,
    date_creation   timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_series_pays ON public.series(pays);
CREATE INDEX IF NOT EXISTS idx_series_type ON public.series(type_examen_id);
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_series_type_examen') THEN
        ALTER TABLE public.series ADD CONSTRAINT fk_series_type_examen
            FOREIGN KEY (type_examen_id) REFERENCES public.types_examen(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 3) matieres_examen (lookup, scoped to a type)
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.matieres_examen (
    id              serial       PRIMARY KEY,
    uuid            uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays            varchar(50)  NOT NULL DEFAULT 'benin',
    type_examen_id  int          NOT NULL,
    nom             varchar(255) NOT NULL,
    description     text         NULL,
    date_creation   timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_matieres_examen_pays ON public.matieres_examen(pays);
CREATE INDEX IF NOT EXISTS idx_matieres_examen_type ON public.matieres_examen(type_examen_id);
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_matieres_examen_type') THEN
        ALTER TABLE public.matieres_examen ADD CONSTRAINT fk_matieres_examen_type
            FOREIGN KEY (type_examen_id) REFERENCES public.types_examen(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 3b) filieres_examen (lookup, scoped to a type) — parallel to matieres_examen
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.filieres_examen (
    id              serial       PRIMARY KEY,
    uuid            uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays            varchar(50)  NOT NULL DEFAULT 'benin',
    type_examen_id  int          NOT NULL,
    nom             varchar(255) NOT NULL,
    description     text         NULL,
    date_creation   timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_filieres_examen_pays ON public.filieres_examen(pays);
CREATE INDEX IF NOT EXISTS idx_filieres_examen_type ON public.filieres_examen(type_examen_id);
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_filieres_examen_type') THEN
        ALTER TABLE public.filieres_examen ADD CONSTRAINT fk_filieres_examen_type
            FOREIGN KEY (type_examen_id) REFERENCES public.types_examen(id) ON DELETE CASCADE;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 4) examens_nationaux (the resource)
--    matiere_examen_id + filiere_examen_id are independent and both optional,
--    but at least one must be set (CHECK).
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.examens_nationaux (
    id                        serial       PRIMARY KEY,
    uuid                      uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays                      varchar(50)  NOT NULL DEFAULT 'benin',
    type_examen_id            int          NOT NULL,
    serie_id                  int          NULL,
    matiere_examen_id         int          NULL,
    filiere_examen_id         int          NULL,
    section                   varchar(30)  NULL,
    annee                     int          NOT NULL,
    titre                     varchar(255) NOT NULL DEFAULT '',
    file_path                 text         NOT NULL DEFAULT '',
    file_extension            varchar(10)  NOT NULL DEFAULT '',
    url                       text         NOT NULL DEFAULT '',
    nombre_pages              int          NOT NULL DEFAULT 0,
    nombre_telechargements    int          NOT NULL DEFAULT 0,
    date_creation             timestamptz  NOT NULL DEFAULT now(),
    CONSTRAINT chk_examens_nationaux_matiere_or_filiere
        CHECK (matiere_examen_id IS NOT NULL OR filiere_examen_id IS NOT NULL)
);
CREATE INDEX IF NOT EXISTS idx_examens_nationaux_pays ON public.examens_nationaux(pays);
CREATE INDEX IF NOT EXISTS idx_examens_nationaux_type ON public.examens_nationaux(type_examen_id);
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_examens_nationaux_type') THEN
        ALTER TABLE public.examens_nationaux ADD CONSTRAINT fk_examens_nationaux_type
            FOREIGN KEY (type_examen_id) REFERENCES public.types_examen(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_examens_nationaux_serie') THEN
        ALTER TABLE public.examens_nationaux ADD CONSTRAINT fk_examens_nationaux_serie
            FOREIGN KEY (serie_id) REFERENCES public.series(id) ON DELETE SET NULL;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_examens_nationaux_matiere') THEN
        ALTER TABLE public.examens_nationaux ADD CONSTRAINT fk_examens_nationaux_matiere
            FOREIGN KEY (matiere_examen_id) REFERENCES public.matieres_examen(id) ON DELETE RESTRICT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_examens_nationaux_filiere') THEN
        ALTER TABLE public.examens_nationaux ADD CONSTRAINT fk_examens_nationaux_filiere
            FOREIGN KEY (filiere_examen_id) REFERENCES public.filieres_examen(id) ON DELETE RESTRICT;
    END IF;
END $$;

-- ---------------------------------------------------------------------------
-- 5) examens_nationaux_submissions (user submit → admin approve queue)
--    Each classifying level may be an existing id OR a proposed free-text name.
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.examens_nationaux_submissions (
    id                        serial       PRIMARY KEY,
    uuid                      uuid         UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    pays                      varchar(50)  NOT NULL DEFAULT 'benin',
    type_examen_id            int          NULL,
    proposed_type             text         NULL,
    serie_id                  int          NULL,
    proposed_serie            text         NULL,
    matiere_examen_id         int          NULL,
    proposed_matiere          text         NULL,
    filiere_examen_id         int          NULL,
    proposed_filiere          text         NULL,
    section                   varchar(30)  NULL,
    annee                     int          NULL,
    titre                     varchar(255) NOT NULL DEFAULT '',
    file_path                 text         NOT NULL DEFAULT '',
    file_extension            varchar(10)  NOT NULL DEFAULT '',
    url                       text         NOT NULL DEFAULT '',
    soumis_par_id             int          NULL,
    status                    varchar(20)  NOT NULL DEFAULT 'pending_approval',
    decline_reason            text         NULL,
    date_creation             timestamptz  NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_exam_nat_sub_status ON public.examens_nationaux_submissions(status);
CREATE INDEX IF NOT EXISTS idx_exam_nat_sub_pays   ON public.examens_nationaux_submissions(pays);
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'fk_exam_nat_sub_soumis_par') THEN
        ALTER TABLE public.examens_nationaux_submissions ADD CONSTRAINT fk_exam_nat_sub_soumis_par
            FOREIGN KEY (soumis_par_id) REFERENCES public.utilisateurs(id) ON DELETE SET NULL;
    END IF;
END $$;

COMMIT;
