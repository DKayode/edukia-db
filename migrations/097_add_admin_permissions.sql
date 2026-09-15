ALTER TABLE utilisateurs
  ADD COLUMN IF NOT EXISTS admin_permissions jsonb NULL;

COMMENT ON COLUMN utilisateurs.admin_permissions IS
  'Permissions du back-office; NULL conserve le comportement super-admin historique.';
