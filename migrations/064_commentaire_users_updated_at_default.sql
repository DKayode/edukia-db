-- 064: commentaire_users.updated_at is NOT NULL but had no default, while
-- created_at is NOT NULL DEFAULT CURRENT_TIMESTAMP. TypeORM does not populate
-- these timestamps here (created_at only survives via its DB default), so every
-- polymorphic comment insert (POST /commentaires/:model/:id — Forums / Parcours
-- / Avis) failed with "null value in column updated_at violates not-null
-- constraint" -> 500. Give updated_at the same default so inserts populate it.
ALTER TABLE commentaire_users
  ALTER COLUMN updated_at SET DEFAULT CURRENT_TIMESTAMP;

-- Defensive backfill (idempotent): the NOT NULL constraint would have blocked
-- any NULL, but harmless to run.
UPDATE commentaire_users SET updated_at = created_at WHERE updated_at IS NULL;
