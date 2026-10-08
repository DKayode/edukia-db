-- 111 — Journaliser les lancements de Ketsia dans resource_access
--
-- L'usage de l'assistante n'était enregistré nulle part (#317, point 1d) :
-- `quota_consommations` ne reçoit une ligne que lorsque le quota KETSIA_AI
-- est actif, et il est désactivé dans les trois pays. Le quota décide, le
-- journal constate : `POST /abonnements/quota/ketsia` écrit désormais une
-- ligne ('ketsia', id de la ressource sur laquelle l'assistante est lancée)
-- à chaque lancement autorisé, et `/kpi` l'expose sous engagement.ketsia.
--
-- Aucune donnée existante n'est touchée : on élargit une contrainte, on ne
-- réécrit rien. Même forme que 083.

BEGIN;

ALTER TABLE public.resource_access
    DROP CONSTRAINT IF EXISTS chk_resource_access_type;

ALTER TABLE public.resource_access
    ADD CONSTRAINT chk_resource_access_type CHECK (
        resource_type IN (
            'epreuve', 'concours', 'examen_national',
            'opportunite', 'offre', 'service', 'evenement',
            'parcours', 'forum', 'publicite',
            'ketsia'
        )
    );

COMMENT ON COLUMN public.resource_access.resource_type IS
    'Type de ressource consultée : ressources académiques (epreuve, concours, '
    'examen_national), fiche de module (opportunite, offre, service, '
    'evenement, parcours, forum, publicite) ou lancement de l''assistante '
    '(ketsia, resource_id = ressource sur laquelle elle est lancée).';

COMMIT;
