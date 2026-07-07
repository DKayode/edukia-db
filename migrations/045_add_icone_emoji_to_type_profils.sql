-- Type-profil icône is now an emoji (e.g. "🎓") instead of an imported file.
-- Additive; the R2 icone slot columns (icone_path/icone_extension) stay but dormant.
ALTER TABLE type_profils ADD COLUMN IF NOT EXISTS icone varchar(32);
