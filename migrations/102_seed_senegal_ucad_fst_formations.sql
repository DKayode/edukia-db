-- 102 - Formations principales de la FST/UCAD (Sénégal).
-- Sources officielles UCAD :
-- - https://fst.ucad.sn/sites/default/files/Livret%20de%20l%27e%CC%81tudiant%20FST_2022_08%20fevier%20%281%29.pdf
-- - https://fst.ucad.sn/node/148

BEGIN;

WITH programmes(nom) AS (
    VALUES
        ('Physique Chimie'),
        ('Sciences de la Vie et de la Terre'),
        ('Mathématique, Physique et Informatique')
)
INSERT INTO public.filieres (pays, nom, etablissement_id)
SELECT 'senegal', p.nom, e.id
FROM programmes p
JOIN public.etablissements e
  ON e.pays = 'senegal'
 AND e.nom = 'Faculté des Sciences et Techniques (FST)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.filieres f
    WHERE f.pays = 'senegal'
      AND f.etablissement_id = e.id
      AND lower(f.nom) = lower(p.nom)
);

WITH niveaux(filiere_nom, niveau) AS (
    VALUES
        ('Physique Chimie', 'Licence 1'),
        ('Physique Chimie', 'Licence 2'),
        ('Physique Chimie', 'Licence 3'),
        ('Physique Chimie', 'Master 1'),
        ('Physique Chimie', 'Master 2'),
        ('Sciences de la Vie et de la Terre', 'Licence 1'),
        ('Sciences de la Vie et de la Terre', 'Licence 2'),
        ('Sciences de la Vie et de la Terre', 'Licence 3'),
        ('Sciences de la Vie et de la Terre', 'Master 1'),
        ('Sciences de la Vie et de la Terre', 'Master 2'),
        ('Mathématique, Physique et Informatique', 'Licence 1'),
        ('Mathématique, Physique et Informatique', 'Licence 2'),
        ('Mathématique, Physique et Informatique', 'Licence 3')
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT n.niveau, 12, f.id, 'senegal'
FROM niveaux n
JOIN public.filieres f
  ON f.pays = 'senegal'
 AND lower(f.nom) = lower(n.filiere_nom)
JOIN public.etablissements e
  ON e.id = f.etablissement_id
 AND e.nom = 'Faculté des Sciences et Techniques (FST)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude existing
    WHERE existing.pays = 'senegal'
      AND existing.filiere_id = f.id
      AND lower(existing.nom) = lower(n.niveau)
);

COMMIT;
