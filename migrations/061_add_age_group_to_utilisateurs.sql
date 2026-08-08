-- Hotfix: use an age GROUP on the user profile instead of the exact birth date.
-- Additive + nullable; date_naissance is kept (KPI age-demographics still read it).
ALTER TABLE utilisateurs ADD COLUMN IF NOT EXISTS age_group varchar(30);
