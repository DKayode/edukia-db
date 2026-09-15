-- 105 - Formations initiales vérifiées de la FMPO/UCAD (Sénégal).
-- Source officielle : https://fmpos.ucad.sn/Formations_initiales
--
-- La page officielle confirme les trois formations initiales et leurs
-- diplômes finaux. Les années détaillées de chaque cursus ne sont pas
-- suffisamment explicites dans cette source et ne sont donc pas inventées.

BEGIN;

WITH programmes(nom, niveau) AS (
    VALUES
        ('Médecine', 'Doctorat de Médecine'),
        ('Pharmacie', 'Doctorat de Pharmacie'),
        ('Odontologie', 'Doctorat d''Odontologie')
)
INSERT INTO public.filieres (pays, nom, etablissement_id)
SELECT 'senegal', p.nom, e.id
FROM programmes p
JOIN public.etablissements e
  ON e.pays = 'senegal'
 AND e.nom = 'Faculté de Médecine, de Pharmacie et d''Odonto-Stomatologie (FMPO)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.filieres f
    WHERE f.pays = 'senegal'
      AND f.etablissement_id = e.id
      AND lower(f.nom) = lower(p.nom)
);

WITH programmes(nom, niveau) AS (
    VALUES
        ('Médecine', 'Doctorat de Médecine'),
        ('Pharmacie', 'Doctorat de Pharmacie'),
        ('Odontologie', 'Doctorat d''Odontologie')
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT p.niveau, NULL, f.id, 'senegal'
FROM programmes p
JOIN public.filieres f
  ON f.pays = 'senegal'
 AND lower(f.nom) = lower(p.nom)
JOIN public.etablissements e
  ON e.id = f.etablissement_id
 AND e.nom = 'Faculté de Médecine, de Pharmacie et d''Odonto-Stomatologie (FMPO)'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude n
    WHERE n.pays = 'senegal'
      AND n.filiere_id = f.id
      AND lower(n.nom) = lower(p.niveau)
);

COMMIT;
