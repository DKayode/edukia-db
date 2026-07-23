-- Type-profil REGISTRY: type_profils associated to a content entity per pays.
-- MANY type_profils per entity (many-to-many at entity level); replaces per-row
-- tagging. The 5 join tables (042) become unused but are kept (non-destructive).
CREATE TABLE IF NOT EXISTS entity_type_profil (
  id            SERIAL PRIMARY KEY,
  entity        varchar(50)  NOT NULL,
  type_profil_id integer     NOT NULL REFERENCES type_profils(id) ON DELETE CASCADE,
  pays          varchar(50)  NOT NULL DEFAULT 'benin',
  date_creation timestamptz  NOT NULL DEFAULT now(),
  CONSTRAINT uq_entity_type_profil UNIQUE (entity, type_profil_id, pays)
);
CREATE INDEX IF NOT EXISTS idx_entity_type_profil_lookup ON entity_type_profil (pays, entity);
