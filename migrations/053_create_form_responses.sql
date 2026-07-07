-- Form response — one user's submission to a campaign.
-- 053 depends on 050. Cascade: campaign → response → answer (054).
--   * id: UUID PK.
--   * campaign_id: uuid NOT NULL, ON DELETE CASCADE.
--   * user_id: integer (utilisateurs.id is a serial int — NOT a uuid).
--   * pays: carried on the row (denormalised) for @CurrentCountry filtering
--     without a join back to the campaign.
--   * UNIQUE(campaign_id, user_id): one submission per user per campaign —
--     the DB guard behind the 409 on re-submit and the "answered" left-join.
--
-- Idempotent: CREATE TABLE / FK guarded / unique + plain indexes guarded.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.form_responses (
    id           uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id  uuid         NOT NULL,
    user_id      integer      NOT NULL,
    pays         varchar(50)  NOT NULL DEFAULT 'benin',
    submitted_at timestamptz  NOT NULL DEFAULT now()
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_form_responses_campaign'
    ) THEN
        ALTER TABLE public.form_responses
            ADD CONSTRAINT fk_form_responses_campaign
            FOREIGN KEY (campaign_id) REFERENCES public.form_campaigns(id)
            ON DELETE CASCADE;
    END IF;
END $$;

CREATE UNIQUE INDEX IF NOT EXISTS uq_form_responses_campaign_user
    ON public.form_responses(campaign_id, user_id);

CREATE INDEX IF NOT EXISTS idx_form_responses_campaign_id
    ON public.form_responses(campaign_id);

CREATE INDEX IF NOT EXISTS idx_form_responses_pays
    ON public.form_responses(pays);

COMMIT;
