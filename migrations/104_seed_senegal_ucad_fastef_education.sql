-- 104 - Formations académiques principales de la FASTEF/UCAD (Sénégal).
-- Sources officielles :
-- - https://fastef.ucad.sn/revuefastef/cuse/cuse_inscription.htm
-- - https://fastef.ucad.sn/revuefastef/offre-formation.htm

BEGIN;

WITH programmes(nom) AS (
    VALUES
        ('Sciences de l''Education et de la Formation'),
        ('Education et Formation')
)
INSERT INTO public.filieres (pays, nom, etablissement_id)
SELECT 'senegal', p.nom, e.id
FROM programmes p
JOIN public.etablissements e
  ON e.pays = 'senegal'
 AND e.nom = 'Faculté des Sciences et Technologies de l''Education et de la Formation (FASTEF)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.filieres f
    WHERE f.pays = 'senegal'
      AND f.etablissement_id = e.id
      AND lower(f.nom) = lower(p.nom)
);

WITH niveaux(filiere_nom, niveau) AS (
    VALUES
        ('Sciences de l''Education et de la Formation', 'Licence 1'),
        ('Sciences de l''Education et de la Formation', 'Licence 2'),
        ('Sciences de l''Education et de la Formation', 'Licence 3'),
        ('Education et Formation', 'Master 1'),
        ('Education et Formation', 'Master 2')
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT n.niveau, 12, f.id, 'senegal'
FROM niveaux n
JOIN public.filieres f
  ON f.pays = 'senegal'
 AND lower(f.nom) = lower(n.filiere_nom)
JOIN public.etablissements e
  ON e.id = f.etablissement_id
 AND e.nom = 'Faculté des Sciences et Technologies de l''Education et de la Formation (FASTEF)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude existing
    WHERE existing.pays = 'senegal'
      AND existing.filiere_id = f.id
      AND lower(existing.nom) = lower(n.niveau)
);

COMMIT;
