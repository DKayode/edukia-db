-- 101 - Licences de la FASEG/UCAD (Sénégal).
-- Source officielle UCAD : https://fad.faseg.ucad.sn/
--
-- La plateforme officielle distingue une licence L1-L2 en Sciences
-- économiques et gestion, puis des parcours L3 en Economie et en Gestion.

BEGIN;

WITH programmes(nom) AS (
    VALUES
        ('Sciences Economiques et Gestion'),
        ('Sciences Economiques - Option Economie'),
        ('Sciences Economiques - Option Gestion')
)
INSERT INTO public.filieres (pays, nom, etablissement_id)
SELECT 'senegal', p.nom, e.id
FROM programmes p
JOIN public.etablissements e
  ON e.pays = 'senegal'
 AND e.nom = 'Faculté des Sciences Economiques et de Gestion (FASEG)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.filieres f
    WHERE f.pays = 'senegal'
      AND f.etablissement_id = e.id
      AND lower(f.nom) = lower(p.nom)
);

WITH niveaux(filiere_nom, niveau) AS (
    VALUES
        ('Sciences Economiques et Gestion', 'Licence 1'),
        ('Sciences Economiques et Gestion', 'Licence 2'),
        ('Sciences Economiques - Option Economie', 'Licence 3'),
        ('Sciences Economiques - Option Gestion', 'Licence 3')
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT n.niveau, 12, f.id, 'senegal'
FROM niveaux n
JOIN public.filieres f
  ON f.pays = 'senegal'
 AND lower(f.nom) = lower(n.filiere_nom)
JOIN public.etablissements e
  ON e.id = f.etablissement_id
 AND e.nom = 'Faculté des Sciences Economiques et de Gestion (FASEG)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude existing
    WHERE existing.pays = 'senegal'
      AND existing.filiere_id = f.id
      AND lower(existing.nom) = lower(n.niveau)
);

COMMIT;
