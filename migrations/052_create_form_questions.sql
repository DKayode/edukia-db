-- Form question (rubric) — a single prompt inside a section.
-- 052 depends on 051. Cascade: section → question.
--   * id: UUID PK.
--   * section_id: uuid NOT NULL, ON DELETE CASCADE.
--   * type: rating | text. `rating` is a 4-point scale stored as smallint 1–4
--     (the emoji/label mapping is frontend-only); `text` is a free answer.
--   * ordre: display order within the section.
--
-- Idempotent: CREATE TABLE / FK guarded by pg_constraint check / index guarded.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.form_questions (
    id         uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    section_id uuid         NOT NULL,
    libelle    varchar(500) NOT NULL,
    type       varchar(20)  NOT NULL CHECK (type IN ('rating', 'text')),
    ordre      int          NOT NULL DEFAULT 0
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_form_questions_section'
    ) THEN
        ALTER TABLE public.form_questions
            ADD CONSTRAINT fk_form_questions_section
            FOREIGN KEY (section_id) REFERENCES public.form_sections(id)
            ON DELETE CASCADE;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_form_questions_section_id
    ON public.form_questions(section_id);

COMMIT;
