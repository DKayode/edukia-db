-- 100 - Licences de la Faculté des Sciences Juridiques et Politiques (UCAD).
-- Source officielle :
-- https://fsjp.ucad.sn/sites/default/files/nomenclature%20de%20nos%20offres%20de%20formation.pdf
--
-- Les intitulés sont conservés comme filières distinctes lorsque la
-- nomenclature officielle les distingue. Les niveaux sont semés idempotemment.

BEGIN;

WITH programmes(nom) AS (
    VALUES
        ('Sciences Juridiques'),
        ('Sciences Politiques'),
        ('Droit Privé'),
        ('Droit Public'),
        ('Droits de l''Homme')
)
INSERT INTO public.filieres (pays, nom, etablissement_id)
SELECT 'senegal', p.nom, e.id
FROM programmes p
JOIN public.etablissements e
  ON e.pays = 'senegal'
 AND e.nom = 'Faculté des Sciences Juridiques et Politiques (FSJP)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.filieres f
    WHERE f.pays = 'senegal'
      AND f.etablissement_id = e.id
      AND lower(f.nom) = lower(p.nom)
);

WITH programmes(nom, niveaux) AS (
    VALUES
        ('Sciences Juridiques', ARRAY['Licence 1', 'Licence 2']::text[]),
        ('Sciences Politiques', ARRAY['Licence 1', 'Licence 2']::text[]),
        ('Droit Privé', ARRAY['Licence 3']::text[]),
        ('Droit Public', ARRAY['Licence 3']::text[]),
        ('Droits de l''Homme', ARRAY['Licence 1', 'Licence 3']::text[])
),
all_filieres AS (
    SELECT f.id, f.nom
    FROM public.filieres f
    JOIN public.etablissements e ON e.id = f.etablissement_id
    WHERE f.pays = 'senegal'
      AND e.nom = 'Faculté des Sciences Juridiques et Politiques (FSJP)'
      AND EXISTS (SELECT 1 FROM programmes p WHERE lower(p.nom) = lower(f.nom))
),
levels AS (
    SELECT af.id AS filiere_id, unnest(p.niveaux) AS nom
    FROM all_filieres af
    JOIN programmes p ON lower(p.nom) = lower(af.nom)
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT l.nom, 12, l.filiere_id, 'senegal'
FROM levels l
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude n
    WHERE n.pays = 'senegal'
      AND n.filiere_id = l.filiere_id
      AND lower(n.nom) = lower(l.nom)
);

COMMIT;
