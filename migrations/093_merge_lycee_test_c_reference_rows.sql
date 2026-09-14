-- 093 - Fusionner les lignes de reference dupliquees pour Lycee Test C.
--
-- Deux lignes de test "Lycee Test C" existent dans la base :
-- - etablissement 147 / filiere 330 porte les matieres et une soumission ;
-- - etablissement 148 / filiere 331 porte le niveau Terminale A.
--
-- Les matieres pointent deja vers la filiere 330 mais vers le niveau 3251,
-- lui-meme rattache a la filiere 331. On garde donc les ids utiles et on
-- rattache le niveau a la filiere 330 avant de supprimer la coquille 331/148.

BEGIN;

UPDATE public.niveau_etude
   SET filiere_id = 330
 WHERE id = 3251
   AND pays = 'benin'
   AND filiere_id = 331
   AND NOT EXISTS (
        SELECT 1
          FROM public.niveau_etude n
         WHERE n.pays = 'benin'
           AND n.filiere_id = 330
           AND lower(n.nom) = lower(public.niveau_etude.nom)
           AND n.id <> public.niveau_etude.id
      );

DELETE FROM public.filieres
 WHERE id = 331
   AND pays = 'benin'
   AND etablissement_id = 148
   AND NOT EXISTS (SELECT 1 FROM public.niveau_etude n WHERE n.filiere_id = 331)
   AND NOT EXISTS (SELECT 1 FROM public.matieres m WHERE m.filiere_id = 331)
   AND NOT EXISTS (SELECT 1 FROM public.utilisateurs u WHERE u.filiere_id = 331)
   AND NOT EXISTS (SELECT 1 FROM public.epreuve_submissions s WHERE s.filiere_id = 331);

DELETE FROM public.etablissements
 WHERE id = 148
   AND pays = 'benin'
   AND nom = 'Lycée Test C'
   AND NOT EXISTS (SELECT 1 FROM public.filieres f WHERE f.etablissement_id = 148)
   AND NOT EXISTS (SELECT 1 FROM public.utilisateurs u WHERE u.etablissement_id = 148)
   AND NOT EXISTS (SELECT 1 FROM public.epreuve_submissions s WHERE s.etablissement_id = 148);

COMMIT;
