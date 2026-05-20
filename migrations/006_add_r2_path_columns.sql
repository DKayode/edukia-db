-- Add per-slot path + extension columns for the new Cloudflare R2 storage
-- pipeline. The path column holds a stable logical identifier
-- (`/<entity>/<uuid>/<slot>`) and the extension column holds the actual file
-- extension that was uploaded; together they let the backend reconstruct the
-- R2 object key on demand.
--
-- The legacy firebase-backed `fichiers` columns are kept untouched during
-- the transition; this migration only adds new columns alongside.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS, safe to re-run per environment.

BEGIN;

-- Single-slot entities
ALTER TABLE public.categories     ADD COLUMN IF NOT EXISTS icone_path             text          NOT NULL DEFAULT '';
ALTER TABLE public.categories     ADD COLUMN IF NOT EXISTS icone_extension        varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.concours       ADD COLUMN IF NOT EXISTS file_path              text          NOT NULL DEFAULT '';
ALTER TABLE public.concours       ADD COLUMN IF NOT EXISTS file_extension         varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.epreuves       ADD COLUMN IF NOT EXISTS file_path              text          NOT NULL DEFAULT '';
ALTER TABLE public.epreuves       ADD COLUMN IF NOT EXISTS file_extension         varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.etablissements ADD COLUMN IF NOT EXISTS logo_path              text          NOT NULL DEFAULT '';
ALTER TABLE public.etablissements ADD COLUMN IF NOT EXISTS logo_extension         varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.evenements     ADD COLUMN IF NOT EXISTS image_path             text          NOT NULL DEFAULT '';
ALTER TABLE public.evenements     ADD COLUMN IF NOT EXISTS image_extension        varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.forums         ADD COLUMN IF NOT EXISTS file_path              text          NOT NULL DEFAULT '';
ALTER TABLE public.forums         ADD COLUMN IF NOT EXISTS file_extension         varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.offres         ADD COLUMN IF NOT EXISTS image_path             text          NOT NULL DEFAULT '';
ALTER TABLE public.offres         ADD COLUMN IF NOT EXISTS image_extension        varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.opportunites   ADD COLUMN IF NOT EXISTS image_path             text          NOT NULL DEFAULT '';
ALTER TABLE public.opportunites   ADD COLUMN IF NOT EXISTS image_extension        varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.ressources     ADD COLUMN IF NOT EXISTS file_path              text          NOT NULL DEFAULT '';
ALTER TABLE public.ressources     ADD COLUMN IF NOT EXISTS file_extension         varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.services       ADD COLUMN IF NOT EXISTS image_path             text          NOT NULL DEFAULT '';
ALTER TABLE public.services       ADD COLUMN IF NOT EXISTS image_extension        varchar(10)   NOT NULL DEFAULT '';
ALTER TABLE public.utilisateurs   ADD COLUMN IF NOT EXISTS profil_photo_path      text          NOT NULL DEFAULT '';
ALTER TABLE public.utilisateurs   ADD COLUMN IF NOT EXISTS profil_photo_extension varchar(10)   NOT NULL DEFAULT '';

-- Two-slot entities
ALTER TABLE public.parcours     ADD COLUMN IF NOT EXISTS covert_image_path        text        NOT NULL DEFAULT '';
ALTER TABLE public.parcours     ADD COLUMN IF NOT EXISTS covert_image_extension   varchar(10) NOT NULL DEFAULT '';
ALTER TABLE public.parcours     ADD COLUMN IF NOT EXISTS content_image_path       text        NOT NULL DEFAULT '';
ALTER TABLE public.parcours     ADD COLUMN IF NOT EXISTS content_image_extension  varchar(10) NOT NULL DEFAULT '';
ALTER TABLE public.publicites   ADD COLUMN IF NOT EXISTS covert_image_path        text        NOT NULL DEFAULT '';
ALTER TABLE public.publicites   ADD COLUMN IF NOT EXISTS covert_image_extension   varchar(10) NOT NULL DEFAULT '';
ALTER TABLE public.publicites   ADD COLUMN IF NOT EXISTS content_image_path       text        NOT NULL DEFAULT '';
ALTER TABLE public.publicites   ADD COLUMN IF NOT EXISTS content_image_extension  varchar(10) NOT NULL DEFAULT '';
ALTER TABLE public.prestataires ADD COLUMN IF NOT EXISTS profil_photo_path        text        NOT NULL DEFAULT '';
ALTER TABLE public.prestataires ADD COLUMN IF NOT EXISTS profil_photo_extension   varchar(10) NOT NULL DEFAULT '';
ALTER TABLE public.prestataires ADD COLUMN IF NOT EXISTS identity_photo_path      text        NOT NULL DEFAULT '';
ALTER TABLE public.prestataires ADD COLUMN IF NOT EXISTS identity_photo_extension varchar(10) NOT NULL DEFAULT '';

COMMIT;
