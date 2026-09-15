-- 098 - Niveaux de la filière Langue Arabe de l'ILACI/UAC (Bénin).
--
-- Sources officielles UAC :
-- - Guide d'orientation des filières de formation MESRS/UAC :
--   https://www.uac.bj/wp-content/uploads/2024/06/Guide_orientation_filiere_de_formation_MESRS-2017vf14.02.2017.pdf
-- - Annuaire statistique UAC 2018-2019 :
--   https://recherche-universitaire.uac.bj/wp-content/uploads/2023/02/Annuaire_Statistiques_2018_2019_UAC_18_10_2020.pdf
--
-- L'annuaire classe explicitement « Langue Arabe » à l'ILACI en Licence
-- professionnelle et présente les années 1, 2 et 3. Le guide décrit également
-- le parcours ILACI comme une formation en quatre années pour la Maîtrise,
-- avec une année préparatoire possible pour les étudiants francophones.
-- La filière actuellement enregistrée dans Edukia est la filière Licence
-- professionnelle « Langue Arabe » (id 130) ; on sème donc uniquement les
-- trois niveaux observés dans cette filière, sans inventer une année
-- préparatoire ou un niveau de Maîtrise.

BEGIN;

WITH niveaux(nom, duree_mois, ordre) AS (
    VALUES
        ('Licence 1', 12, 1),
        ('Licence 2', 12, 2),
        ('Licence 3', 12, 3)
)
INSERT INTO public.niveau_etude (nom, duree_mois, filiere_id, pays)
SELECT n.nom, n.duree_mois, f.id, f.pays
FROM niveaux n
JOIN public.filieres f
  ON f.id = 130
 AND f.pays = 'benin'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.niveau_etude existing
    WHERE existing.filiere_id = f.id
      AND existing.pays = f.pays
      AND lower(existing.nom) = lower(n.nom)
);

COMMIT;
