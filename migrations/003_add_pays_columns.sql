-- Single-database country scoping: add `pays` to user-facing and admin-curated
-- tables. Existing rows backfill to 'benin' (the launch country); new inserts
-- carry the country picked by the client and validated against config.json
-- on the backend.
--
-- Scoped tables: 24 (mix of user-generated content and admin-curated reference
-- data). Tables intentionally excluded: utilisateurs (cross-country accounts),
-- competences/types (cross-country taxonomies), auth tables, notifications,
-- app_versions, desabonnement_email.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS, safe to re-run per environment.

BEGIN;

-- User-generated content
ALTER TABLE public.forums                  ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.offres                  ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.services                ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.avis                    ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.commentaire_users       ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.like_users              ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.commentaires            ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.likes                   ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.favoris                 ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.parcours                ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.prestataires            ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.recruteurs              ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';

-- Admin-curated reference content
ALTER TABLE public.epreuves                ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.ressources              ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.concours                ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.evenements              ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.opportunites            ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.publicites              ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.categories              ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.contacts_professionnels ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.etablissements          ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.filieres                ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.niveau_etude            ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';
ALTER TABLE public.matieres                ADD COLUMN IF NOT EXISTS pays varchar(50) NOT NULL DEFAULT 'benin';

-- Indexes for the most frequently filtered tables. Non-blocking thanks to
-- IF NOT EXISTS; CREATE INDEX without CONCURRENTLY because we're inside a
-- transaction. Use CONCURRENTLY in a separate migration if these tables
-- get hot enough to need it.
CREATE INDEX IF NOT EXISTS idx_forums_pays                  ON public.forums(pays);
CREATE INDEX IF NOT EXISTS idx_offres_pays                  ON public.offres(pays);
CREATE INDEX IF NOT EXISTS idx_services_pays                ON public.services(pays);
CREATE INDEX IF NOT EXISTS idx_parcours_pays                ON public.parcours(pays);
CREATE INDEX IF NOT EXISTS idx_epreuves_pays                ON public.epreuves(pays);
CREATE INDEX IF NOT EXISTS idx_ressources_pays              ON public.ressources(pays);
CREATE INDEX IF NOT EXISTS idx_concours_pays                ON public.concours(pays);
CREATE INDEX IF NOT EXISTS idx_evenements_pays              ON public.evenements(pays);
CREATE INDEX IF NOT EXISTS idx_opportunites_pays            ON public.opportunites(pays);
CREATE INDEX IF NOT EXISTS idx_publicites_pays              ON public.publicites(pays);

COMMIT;
