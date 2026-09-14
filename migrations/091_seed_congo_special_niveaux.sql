-- 091 - Niveaux source-backed pour les filieres UMNG manquantes du Congo.
--
-- Contexte mobile :
-- Les listes imbriquees etablissement -> filiere -> niveau doivent afficher les
-- enfants configures meme si aucune epreuve n'existe encore. Cette migration
-- complete les filieres congolaises pour lesquelles une source officielle donne
-- la structure.
--
-- Sources :
-- - https://www.sgg.cg/JO/2009/congo-jo-2009-26.pdf
--   Decret appliquant le systeme Licence, Master, Doctorat a l'Universite
--   Marien Ngouabi.
-- - https://www.sgg.cg/JO/2010/congo-jo-2010-10.pdf
--   Arrete fixant l'organisation des etudes dans le cadre du systeme LMD a
--   l'Universite Marien Ngouabi.
-- - https://www.umng.cg/?q=fr/node/77
--   Page officielle "Programmes" de l'Universite Marien Ngouabi :
--   * FSSA : sciences infirmieres en Licences et Masters ; Medecine : 7 ans.
--   * ISEPS : Licences professionnelles en EPS/Sport ; Masters recherches et
--     professionnelles en activites physiques et sportives.
--
-- Deliberement exclu :
-- - filiere_id 279 Pharmacie : pas listee directement dans la page officielle
--   utilisee ici. A semer seulement apres source directe ou confirmation admin.

BEGIN;

WITH ordinary_lmd_filieres(filiere_id) AS (
    VALUES
        (272), (273),
        (282),
        (286), (287), (288), (289),
        (296), (297), (299), (300), (302), (303), (304), (308),
        (319), (322)
),
special_lmd_filieres(filiere_id) AS (
    VALUES
        (280),
        (323),
        (324)
),
lmd_levels(niveau, duree_mois) AS (
    VALUES
        ('Licence 1', 12),
        ('Licence 2', 12),
        ('Licence 3', 12),
        ('Master 1', 12),
        ('Master 2', 12)
),
candidates(filiere_id, niveau, duree_mois) AS (
    SELECT f.filiere_id, l.niveau, l.duree_mois
      FROM ordinary_lmd_filieres f
      CROSS JOIN lmd_levels l
    UNION ALL
    SELECT f.filiere_id, l.niveau, l.duree_mois
      FROM special_lmd_filieres f
      CROSS JOIN lmd_levels l
    UNION ALL
    SELECT 278, 'Medecine ' || annee::text, 12
      FROM generate_series(1, 7) AS years(annee)
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT c.niveau, c.duree_mois, f.id, f.pays
  FROM candidates c
  JOIN public.filieres f
    ON f.id = c.filiere_id
   AND f.pays = 'congo'
 WHERE NOT EXISTS (
        SELECT 1
          FROM public.niveau_etude n
         WHERE n.filiere_id = f.id
           AND n.pays = f.pays
           AND lower(n.nom) = lower(c.niveau)
      );

COMMIT;
