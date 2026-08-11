-- Journal des connexions, en ajout seul.
--
-- Les KPI « utilisateurs connectés » / « apprenants connectés » comptaient
-- jusqu'ici des lignes de refresh_tokens. Ce n'est pas un journal : à chaque
-- connexion, createRefreshToken() SUPPRIME la ligne précédente de l'appareil
-- puis en insère une nouvelle. Il reste donc une ligne par utilisateur et par
-- appareil (18 246 personnes sur 18 249 n'en ont qu'une), portant la date de la
-- DERNIÈRE connexion.
--
-- Deux conséquences :
--   1. une personne connectée plusieurs fois n'est comptée que dans la période
--      de sa dernière connexion — l'activité récurrente disparaît ;
--   2. un rapport rejoué plus tard donne un chiffre DIFFÉRENT pour la même
--      période passée, puisque la ligne se déplace à chaque nouvelle connexion.
--
-- Cette table ne supprime ni ne met à jour : une ligne par connexion réussie.
BEGIN;

CREATE TABLE IF NOT EXISTS login_events (
    id             bigserial   PRIMARY KEY,
    utilisateur_id integer     NOT NULL REFERENCES utilisateurs(id) ON DELETE CASCADE,
    pays           varchar(50) NOT NULL DEFAULT 'benin',
    appareil       varchar(20) NULL,
    date_creation  timestamptz NOT NULL DEFAULT now()
);

-- Le KPI filtre par pays sur une fenêtre de dates, puis compte les personnes
-- distinctes : cet index couvre exactement cette requête.
CREATE INDEX IF NOT EXISTS idx_login_events_pays_date
    ON login_events (pays, date_creation);

CREATE INDEX IF NOT EXISTS idx_login_events_utilisateur_date
    ON login_events (utilisateur_id, date_creation);

COMMIT;
