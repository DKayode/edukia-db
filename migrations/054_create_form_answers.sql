-- Form answer — one user's answer to one question, inside a response.
-- 054 depends on 053 (response) and 052 (question).
--   * id: UUID PK.
--   * response_id: uuid NOT NULL, ON DELETE CASCADE — answers die with their
--     response.
--   * question_id: uuid NOT NULL, ON DELETE CASCADE — answers die with their
--     question (whole-tree replace on builder save).
--   * rating smallint 1–4 for `rating` questions; texte for `text` questions.
--     Exactly one is populated per row (enforced by the app, not the schema).
--
-- Idempotent: CREATE TABLE / FKs guarded / indexes guarded.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.form_answers (
    id          uuid     PRIMARY KEY DEFAULT gen_random_uuid(),
    response_id uuid     NOT NULL,
    question_id uuid     NOT NULL,
    rating      smallint NULL CHECK (rating BETWEEN 1 AND 4),
    texte       text     NULL
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_form_answers_response'
    ) THEN
        ALTER TABLE public.form_answers
            ADD CONSTRAINT fk_form_answers_response
            FOREIGN KEY (response_id) REFERENCES public.form_responses(id)
            ON DELETE CASCADE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_form_answers_question'
    ) THEN
        ALTER TABLE public.form_answers
            ADD CONSTRAINT fk_form_answers_question
            FOREIGN KEY (question_id) REFERENCES public.form_questions(id)
            ON DELETE CASCADE;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_form_answers_response_id
    ON public.form_answers(response_id);

CREATE INDEX IF NOT EXISTS idx_form_answers_question_id
    ON public.form_answers(question_id);

COMMIT;
