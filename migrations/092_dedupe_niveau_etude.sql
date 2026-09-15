-- 092 - Dedoublonner les niveaux d'etude.
--
-- Certains imports ont cree plusieurs lignes niveau_etude avec le meme
-- pays + filiere + libelle, notamment au Benin. Les anciennes lignes portent
-- parfois des matieres, utilisateurs ou soumissions ; on migre donc les
-- references vers une ligne canonique avant suppression.
--
-- Regle de conservation :
-- - garder d'abord la ligne qui a une duree_mois renseignee ;
-- - a egalite, garder l'id le plus recent.

BEGIN;

WITH duplicate_rows AS (
    SELECT
        id,
        FIRST_VALUE(id) OVER (
            PARTITION BY pays, filiere_id, lower(nom)
            ORDER BY (duree_mois IS NOT NULL) DESC, id DESC
        ) AS keep_id,
        COUNT(*) OVER (PARTITION BY pays, filiere_id, lower(nom)) AS group_count
    FROM public.niveau_etude
),
to_merge AS (
    SELECT id AS duplicate_id, keep_id
      FROM duplicate_rows
     WHERE group_count > 1
       AND id <> keep_id
)
UPDATE public.matieres m
   SET niveau_etude_id = tm.keep_id
  FROM to_merge tm
 WHERE m.niveau_etude_id = tm.duplicate_id;

WITH duplicate_rows AS (
    SELECT
        id,
        FIRST_VALUE(id) OVER (
            PARTITION BY pays, filiere_id, lower(nom)
            ORDER BY (duree_mois IS NOT NULL) DESC, id DESC
        ) AS keep_id,
        COUNT(*) OVER (PARTITION BY pays, filiere_id, lower(nom)) AS group_count
    FROM public.niveau_etude
),
to_merge AS (
    SELECT id AS duplicate_id, keep_id
      FROM duplicate_rows
     WHERE group_count > 1
       AND id <> keep_id
)
UPDATE public.utilisateurs u
   SET niveau_etude_id = tm.keep_id
  FROM to_merge tm
 WHERE u.niveau_etude_id = tm.duplicate_id;

WITH duplicate_rows AS (
    SELECT
        id,
        FIRST_VALUE(id) OVER (
            PARTITION BY pays, filiere_id, lower(nom)
            ORDER BY (duree_mois IS NOT NULL) DESC, id DESC
        ) AS keep_id,
        COUNT(*) OVER (PARTITION BY pays, filiere_id, lower(nom)) AS group_count
    FROM public.niveau_etude
),
to_merge AS (
    SELECT id AS duplicate_id, keep_id
      FROM duplicate_rows
     WHERE group_count > 1
       AND id <> keep_id
)
UPDATE public.epreuve_submissions s
   SET niveau_etude_id = tm.keep_id
  FROM to_merge tm
 WHERE s.niveau_etude_id = tm.duplicate_id;

WITH duplicate_rows AS (
    SELECT
        id,
        FIRST_VALUE(id) OVER (
            PARTITION BY pays, filiere_id, lower(nom)
            ORDER BY (duree_mois IS NOT NULL) DESC, id DESC
        ) AS keep_id,
        COUNT(*) OVER (PARTITION BY pays, filiere_id, lower(nom)) AS group_count
    FROM public.niveau_etude
)
DELETE FROM public.niveau_etude n
 USING duplicate_rows d
 WHERE n.id = d.id
   AND d.group_count > 1
   AND d.id <> d.keep_id;

CREATE UNIQUE INDEX IF NOT EXISTS uq_niveau_etude_pays_filiere_nom_ci
    ON public.niveau_etude (pays, filiere_id, lower(nom));

COMMIT;
