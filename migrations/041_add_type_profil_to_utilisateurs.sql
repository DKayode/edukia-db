-- 041_add_type_profil_to_utilisateurs.sql
-- Each user has EXACTLY ONE type-profil: a single nullable FK on utilisateurs.
-- ON DELETE SET NULL so deleting a type-profil just un-assigns affected users.
-- Idempotent.

ALTER TABLE utilisateurs ADD COLUMN IF NOT EXISTS type_profil_id integer;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'utilisateurs_type_profil_id_fkey'
      AND table_name = 'utilisateurs'
      AND table_schema = 'public'
  ) THEN
    ALTER TABLE utilisateurs
      ADD CONSTRAINT utilisateurs_type_profil_id_fkey
      FOREIGN KEY (type_profil_id) REFERENCES type_profils(id) ON DELETE SET NULL;
  END IF;
END $$;
