-- 043_add_uuid_to_type_profils.sql
-- The R2 FilesModule registry resolves the owning row by uuid
-- (SELECT id FROM type_profils WHERE uuid = $1), so type_profils needs a uuid
-- column for the icône upload slot to work. Mirrors categories.uuid exactly.
-- Idempotent.

ALTER TABLE type_profils ADD COLUMN IF NOT EXISTS uuid uuid NOT NULL DEFAULT gen_random_uuid();
CREATE UNIQUE INDEX IF NOT EXISTS type_profils_uuid_key ON type_profils(uuid);
