-- Register `recruteurs` in the R2 files pipeline.
--
-- Recruteurs were skipped in the Firebase→R2 migration (no recruteur photos
-- existed at the time), so — unlike their sibling `prestataires` — the table
-- never got a `uuid` column (migration 002) nor the R2 path/extension columns
-- (migration 006). The /files endpoints resolve every entity row by uuid, so a
-- recruteur profile photo is impossible until those columns exist.
--
-- This mirrors the `prestataires.profil` slot shape exactly:
--   * uuid                    — external identifier the /files pipeline keys on
--   * profil_photo_path       — full public R2 URL (public slot stores the URL)
--   * profil_photo_extension  — uploaded file extension
--
-- The volatile gen_random_uuid() DEFAULT is evaluated per-row during the
-- ADD COLUMN table rewrite, so existing rows are backfilled with distinct
-- uuids automatically (same one-shot approach as migration 002). The explicit
-- UPDATE below is a belt-and-braces backfill in case the column already
-- existed as nullable from a partial prior run.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS + CREATE UNIQUE INDEX IF NOT EXISTS,
-- safe to re-run per environment.

BEGIN;

ALTER TABLE public.recruteurs ADD COLUMN IF NOT EXISTS uuid                   uuid        NOT NULL DEFAULT gen_random_uuid();
ALTER TABLE public.recruteurs ADD COLUMN IF NOT EXISTS profil_photo_path      text        NOT NULL DEFAULT '';
ALTER TABLE public.recruteurs ADD COLUMN IF NOT EXISTS profil_photo_extension varchar(10) NOT NULL DEFAULT '';

-- Backfill any rows that somehow carry a NULL uuid (defensive; the NOT NULL
-- DEFAULT above already covers a clean run).
UPDATE public.recruteurs SET uuid = gen_random_uuid() WHERE uuid IS NULL;

CREATE UNIQUE INDEX IF NOT EXISTS recruteurs_uuid_key ON public.recruteurs(uuid);

COMMIT;
