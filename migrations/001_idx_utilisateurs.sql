CREATE INDEX IF NOT EXISTS idx_utilisateurs_parrain_id ON utilisateurs(parrain_id);
CREATE INDEX IF NOT EXISTS idx_utilisateurs_role ON utilisateurs(role);
CREATE INDEX IF NOT EXISTS idx_utilisateurs_est_desactive ON utilisateurs(est_desactive);
