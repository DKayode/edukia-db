-- 040_create_type_profils.sql
-- Reference entity "Type profil" (titre, sous-titre, icône image).
-- Icône stored via the R2 FilesModule registry pattern: column NAMES mirror
-- categories.icone (icone_path / icone_extension), but both stay NULLABLE so an
-- admin can create a type-profil before any icône is uploaded.
-- Idempotent.

CREATE TABLE IF NOT EXISTS type_profils (
    id              serial PRIMARY KEY,
    titre           varchar(255) NOT NULL,
    sous_titre      varchar(255),
    icone_path      varchar,
    icone_extension varchar,
    pays            varchar(50) NOT NULL DEFAULT 'benin',
    date_creation   timestamptz DEFAULT now()
);
