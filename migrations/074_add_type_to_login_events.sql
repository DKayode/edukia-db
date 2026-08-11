-- Distinguer une authentification explicite d'un renouvellement de session.
--
-- 073 n'enregistrait que POST /auth/connexion. Or le jeton d'accès dure 1 jour
-- et le jeton de rafraîchissement 30 : une personne qui garde sa session ouverte
-- passe par /auth/refresh et ne repasse par /auth/connexion qu'après une
-- réinstallation, une déconnexion explicite ou 30 jours d'inactivité.
--
-- Les utilisateurs les PLUS actifs étaient donc les moins comptés — le défaut
-- que 073 corrigeait, déplacé plutôt que supprimé. On journalise désormais aussi
-- le rafraîchissement, en gardant les deux natures séparables :
--   'connexion' — saisie des identifiants
--   'refresh'   — session renouvelée sans ressaisie
--
-- Les KPI « connectés » comptent les personnes distinctes toutes natures
-- confondues : c'est l'activité réelle sur la période.
BEGIN;

ALTER TABLE login_events
    ADD COLUMN IF NOT EXISTS type varchar(20) NOT NULL DEFAULT 'connexion';

-- Le KPI filtre sur (pays, date) ; cet index sert aux ventilations par nature.
CREATE INDEX IF NOT EXISTS idx_login_events_type_date
    ON login_events (type, date_creation);

COMMIT;
