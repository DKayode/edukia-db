-- 042_create_entity_type_profil_joins.sql
-- Many-to-many "checking list" between each of the 5 content entities and
-- type_profils. An entity with NO rows here is UNTAGGED = public to everyone;
-- tagging only NARROWS the audience to matching type-profils.
-- Composite PK (entity_id, type_profil_id); both FKs ON DELETE CASCADE.
-- All parent PKs verified as `id integer` on edukia-dev. Idempotent.

CREATE TABLE IF NOT EXISTS opportunite_type_profils (
    opportunite_id integer NOT NULL REFERENCES opportunites(id) ON DELETE CASCADE,
    type_profil_id integer NOT NULL REFERENCES type_profils(id) ON DELETE CASCADE,
    PRIMARY KEY (opportunite_id, type_profil_id)
);

CREATE TABLE IF NOT EXISTS evenement_type_profils (
    evenement_id   integer NOT NULL REFERENCES evenements(id)   ON DELETE CASCADE,
    type_profil_id integer NOT NULL REFERENCES type_profils(id) ON DELETE CASCADE,
    PRIMARY KEY (evenement_id, type_profil_id)
);

CREATE TABLE IF NOT EXISTS forum_type_profils (
    forum_id       integer NOT NULL REFERENCES forums(id)       ON DELETE CASCADE,
    type_profil_id integer NOT NULL REFERENCES type_profils(id) ON DELETE CASCADE,
    PRIMARY KEY (forum_id, type_profil_id)
);

CREATE TABLE IF NOT EXISTS service_type_profils (
    service_id     integer NOT NULL REFERENCES services(id)     ON DELETE CASCADE,
    type_profil_id integer NOT NULL REFERENCES type_profils(id) ON DELETE CASCADE,
    PRIMARY KEY (service_id, type_profil_id)
);

CREATE TABLE IF NOT EXISTS offre_type_profils (
    offre_id       integer NOT NULL REFERENCES offres(id)       ON DELETE CASCADE,
    type_profil_id integer NOT NULL REFERENCES type_profils(id) ON DELETE CASCADE,
    PRIMARY KEY (offre_id, type_profil_id)
);
