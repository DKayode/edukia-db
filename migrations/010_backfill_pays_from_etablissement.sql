-- Backfill `pays` for the education hierarchy from its source of truth, the
-- parent Etablissement, cascading down the FK chain. Historically the child
-- `pays` columns defaulted to 'benin' (migration 003) and the create paths
-- either ignored country or used the request country switcher, so a Filiere
-- under a `congo` Etablissement could wrongly read 'benin'. This corrects every
-- mis-scoped row so the admin lists display under the right country.
--
-- FK chain (each child derives from its IMMEDIATE parent):
--   filieres.etablissement_id  -> etablissements.id
--   niveau_etude.filiere_id    -> filieres.id
--   matieres.niveau_etude_id   -> niveau_etude.id   (canonical parent; matieres
--                                 also carries a denormalized filiere_id which
--                                 we intentionally do NOT use for pays)
--   epreuves.matiere_id        -> matieres.id
--
-- Order is parents-first and the whole thing runs in ONE transaction, so each
-- level reads its parent's ALREADY-corrected pays and the fix cascades up to
-- the Etablissement root in a single pass.
--
-- Idempotent: each UPDATE is guarded by `child.pays IS DISTINCT FROM parent.pays`,
-- so a re-run touches 0 rows. Non-destructive: only the `pays` column changes,
-- only where it disagrees with the parent. Safe to re-run per environment.

BEGIN;

-- 1. Filieres <- Etablissements (root source of truth)
UPDATE public.filieres AS f
SET pays = e.pays
FROM public.etablissements AS e
WHERE f.etablissement_id = e.id
  AND f.pays IS DISTINCT FROM e.pays;

-- 2. NiveauEtude <- Filieres (now corrected above)
UPDATE public.niveau_etude AS ne
SET pays = f.pays
FROM public.filieres AS f
WHERE ne.filiere_id = f.id
  AND ne.pays IS DISTINCT FROM f.pays;

-- 3. Matieres <- NiveauEtude (now corrected above); niveau_etude_id is the
--    canonical parent, NOT the denormalized matieres.filiere_id.
UPDATE public.matieres AS m
SET pays = ne.pays
FROM public.niveau_etude AS ne
WHERE m.niveau_etude_id = ne.id
  AND m.pays IS DISTINCT FROM ne.pays;

-- 4. Epreuves <- Matieres (now corrected above)
UPDATE public.epreuves AS ep
SET pays = m.pays
FROM public.matieres AS m
WHERE ep.matiere_id = m.id
  AND ep.pays IS DISTINCT FROM m.pays;

COMMIT;
