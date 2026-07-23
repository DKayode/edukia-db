-- Hotfix: age_group (predefined values) fully replaces the birth date.
-- Destructive: drops the date_naissance column (data loss). KPI age demographics
-- now derive from age_group. Apply to prod only when ready.
ALTER TABLE utilisateurs DROP COLUMN IF EXISTS date_naissance;
