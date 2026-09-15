-- 103 - Licences principales de la FLSH/UCAD (Sénégal).
-- Source officielle UCAD : https://studentcenter.ucad.sn/types-etablissement
-- Note: l'URL historique de l'offre UCAD est publiée par l'université;
-- les cinq parcours de licence sont normalisés ici en niveaux L1-L3.

BEGIN;

WITH programmes(nom) AS (
    VALUES
        ('Langue et Littérature'),
        ('Histoire - Géographie'),
        ('Anglais'),
        ('Philosophie - Sociologie - Psychologie'),
        ('Sciences de l''information et de la Communication')
)
INSERT INTO public.filieres (pays, nom, etablissement_id)
SELECT 'senegal', p.nom, e.id
FROM programmes p
JOIN public.etablissements e
  ON e.pays = 'senegal'
 AND e.nom = 'Faculté des Lettres et Sciences Humaines (FLSH)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.filieres f
    WHERE f.pays = 'senegal'
      AND f.etablissement_id = e.id
      AND lower(f.nom) = lower(p.nom)
);

WITH niveaux(filiere_nom, niveau) AS (
    SELECT p.nom, 'Licence ' || n::text
    FROM (VALUES
        ('Langue et Littérature'),
        ('Histoire - Géographie'),
        ('Anglais'),
        ('Philosophie - Sociologie - Psychologie'),
        ('Sciences de l''information et de la Communication')
    ) AS p(nom)
    CROSS JOIN generate_series(1, 3) AS levels(n)
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT n.niveau, 12, f.id, 'senegal'
FROM niveaux n
JOIN public.filieres f
  ON f.pays = 'senegal'
 AND lower(f.nom) = lower(n.filiere_nom)
JOIN public.etablissements e
  ON e.id = f.etablissement_id
 AND e.nom = 'Faculté des Lettres et Sciences Humaines (FLSH)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude existing
    WHERE existing.pays = 'senegal'
      AND existing.filiere_id = f.id
      AND lower(existing.nom) = lower(n.niveau)
);

COMMIT;
