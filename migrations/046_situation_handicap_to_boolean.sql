-- Hotfix: utilisateurs.situation_handicap varchar -> boolean.
-- Existing values map: NULL / 'aucun' => false ; any other (visuel/auditif/…) => true.
-- Drops the old CHECK (enum values) that would otherwise reject the boolean cast.
-- Idempotent: only converts if the column isn't already boolean.
DO $$
BEGIN
  IF (SELECT data_type FROM information_schema.columns
      WHERE table_name = 'utilisateurs' AND column_name = 'situation_handicap') <> 'boolean' THEN
    ALTER TABLE utilisateurs DROP CONSTRAINT IF EXISTS utilisateurs_situation_handicap_check;
    ALTER TABLE utilisateurs ALTER COLUMN situation_handicap DROP DEFAULT;
    ALTER TABLE utilisateurs
      ALTER COLUMN situation_handicap TYPE boolean
      USING (situation_handicap IS NOT NULL AND lower(situation_handicap) <> 'aucun');
    ALTER TABLE utilisateurs ALTER COLUMN situation_handicap SET DEFAULT false;
  END IF;
END $$;
