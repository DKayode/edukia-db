-- 083 — Étendre le journal de consultation aux autres modules
--
-- `resource_access` ne connaissait que 'epreuve', 'concours' et
-- 'examen_national' : l'intérêt des utilisateurs pour les opportunités, les
-- offres JobKia, les événements ou les parcours n'était mesuré nulle part.
-- Les KPI de l'issue #260 s'appuient sur ce journal ; sans ces types, ils
-- liraient 0 indéfiniment.
--
-- Aucune donnée existante n'est touchée : on élargit une contrainte, on ne
-- réécrit rien.

BEGIN;

ALTER TABLE public.resource_access
    DROP CONSTRAINT IF EXISTS chk_resource_access_type;

ALTER TABLE public.resource_access
    ADD CONSTRAINT chk_resource_access_type CHECK (
        resource_type IN (
            'epreuve', 'concours', 'examen_national',
            'opportunite', 'offre', 'service', 'evenement',
            'parcours', 'forum', 'publicite'
        )
    );

-- Les requêtes KPI filtrent toutes sur (pays, resource_type) et bornent
-- accessed_at. L'index existant ne porte que sur accessed_at, ce qui obligeait
-- à parcourir toutes les lignes de la fenêtre avant de filtrer le type — sur
-- un journal qui grossit d'un ordre de grandeur en s'ouvrant à sept modules,
-- ça ne tient pas.
CREATE INDEX IF NOT EXISTS idx_resource_access_pays_type_date
    ON public.resource_access (pays, resource_type, accessed_at);

COMMENT ON COLUMN public.resource_access.resource_type IS
    'Type de ressource consultée : ressources académiques (epreuve, concours, '
    'examen_national) ou fiche de module (opportunite, offre, service, '
    'evenement, parcours, forum, publicite).';

COMMIT;
