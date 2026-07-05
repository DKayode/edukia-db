-- User profile geo cascade: departement_id + ville_id on utilisateurs.
-- Both are nullable UUID FKs (matching the departements/villes UUID PKs) so
-- existing rows stay valid with no backfill. ON DELETE SET NULL keeps a user
-- alive if their referenced département/ville is removed.
--
-- SCOPE: only these two columns change. utilisateurs.id stays int, and no
-- other column (type_profil_id, etablissement_id, filiere_id, niveau_etude_id)
-- is touched here.
--
-- The cascade constraint (ville must belong to the chosen département,
-- département must belong to the user's pays) is enforced in the service
-- layer on profile update, not by the DB.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS + FK constraints guarded by
-- pg_constraint existence checks.

BEGIN;

ALTER TABLE public.utilisateurs ADD COLUMN IF NOT EXISTS departement_id uuid NULL;
ALTER TABLE public.utilisateurs ADD COLUMN IF NOT EXISTS ville_id       uuid NULL;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_utilisateurs_departement'
    ) THEN
        ALTER TABLE public.utilisateurs
            ADD CONSTRAINT fk_utilisateurs_departement
            FOREIGN KEY (departement_id) REFERENCES public.departements(id)
            ON DELETE SET NULL;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'fk_utilisateurs_ville'
    ) THEN
        ALTER TABLE public.utilisateurs
            ADD CONSTRAINT fk_utilisateurs_ville
            FOREIGN KEY (ville_id) REFERENCES public.villes(id)
            ON DELETE SET NULL;
    END IF;
END $$;

CREATE INDEX IF NOT EXISTS idx_utilisateurs_departement_id ON public.utilisateurs(departement_id);
CREATE INDEX IF NOT EXISTS idx_utilisateurs_ville_id       ON public.utilisateurs(ville_id);

COMMIT;
