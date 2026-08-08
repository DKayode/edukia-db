-- Carry the épreuve `type` through the user-submission flow: a mobile submission
-- can now declare its type (e.g. 'Examens Nationaux'), and approval copies it
-- onto the created épreuve. Reuses the existing native enum `epreuves_type_enum`
-- (same value space as epreuves.type). Nullable — legacy submissions have no type.
-- Idempotent.
ALTER TABLE epreuve_submissions
  ADD COLUMN IF NOT EXISTS type "epreuves_type_enum" NULL;
