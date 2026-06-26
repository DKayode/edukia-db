-- Retire the `ressources` education entity entirely (DROP — data loss approved).
-- The ressources domain (backend module, endpoints, frontend page) has been
-- removed in code; this drops its table + enum so nothing dangling remains.
--
-- `ressources` only has OUTBOUND foreign keys (matiere_id -> matieres,
-- professeur_id -> utilisateurs) and owns its own sequence ressources_id_seq;
-- no other table references it (verified against schemas/base_schema.sql). So
-- DROP TABLE ... CASCADE cleanly removes the table, its FKs, pkey and sequence,
-- and we then drop the now-unused enum type.
--
-- Idempotent: IF EXISTS guards make the file safe to re-run.

BEGIN;

DROP TABLE IF EXISTS public.ressources CASCADE;   -- CASCADE clears its FKs/seq
DROP TYPE IF EXISTS public.ressources_type_enum;

COMMIT;
