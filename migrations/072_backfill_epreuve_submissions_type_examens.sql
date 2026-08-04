-- Backfill: les soumissions d'épreuves antérieures à la migration 071 ont
-- type = NULL. Toutes les épreuves sont désormais soit « Examens » soit
-- « Examens Nationaux » ; on fixe donc les NULL restants à « Examens » (le
-- défaut), pour que la donnée corresponde à ce que l'API expose déjà.
-- Idempotent : ne touche que les lignes encore à NULL.
UPDATE epreuve_submissions
SET type = 'Examens'
WHERE type IS NULL;
