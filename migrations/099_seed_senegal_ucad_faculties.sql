-- 099 - Premiers établissements du Sénégal : facultés UCAD.
-- Source officielle : https://studentcenter.ucad.sn/types-etablissement
--
-- Les filières et niveaux seront importés séparément après normalisation des
-- formations publiées par chaque faculté.

BEGIN;

INSERT INTO public.etablissements (pays, nom, ville)
SELECT 'senegal', v.nom, 'Dakar'
FROM (VALUES
    ('Faculté de Médecine, de Pharmacie et d''Odonto-Stomatologie (FMPO)'),
    ('Faculté des Sciences Juridiques et Politiques (FSJP)'),
    ('Faculté des Sciences Economiques et de Gestion (FASEG)'),
    ('Faculté des Sciences et Techniques (FST)'),
    ('Faculté des Lettres et Sciences Humaines (FLSH)'),
    ('Faculté des Sciences et Technologies de l''Education et de la Formation (FASTEF)')
) AS v(nom)
WHERE NOT EXISTS (
    SELECT 1
    FROM public.etablissements e
    WHERE e.pays = 'senegal'
      AND lower(e.nom) = lower(v.nom)
);

COMMIT;
