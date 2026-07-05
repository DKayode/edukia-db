-- Form section — a titled block (titre + emoji icône) inside a campaign.
-- 051 depends on 050. Cascade: campaign → section → question.
--   * id: UUID PK (matches the form_campaigns decision).
--   * campaign_id: uuid NOT NULL, ON DELETE CASCADE — a section cannot exist
--     without its campaign; the builder replaces the whole tree on save.
--   * ordre: display order within the campaign.
--
-- Idempotent: CREATE TABLE / FK guarded by pg_constraint check / index guarded.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.form_sections (
    id          uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id uuid         NOT NULL,
    titre       varchar(255) NOT NULL,
    icone       varchar(50)  NULL,
    ordre       int          NOT NULL DEFAULT 0
);

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_form_sections_campaign'
    ) THEN
        ALTER TABLE public.form_sections
            ADD CONSTRAINT fk_form_sections_campaign
            FOREIGN KEY (campaign_id) REFERENCES public.form_campaigns(id)
            ON DELETE CASCADE;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_form_sections_campaign_id
    ON public.form_sections(campaign_id);

COMMIT;
