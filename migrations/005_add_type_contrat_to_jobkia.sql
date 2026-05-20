-- Add type_contrat to JobKia tables (services, offres).
--
-- Required field, three values: 'presentiel' | 'hybride' | 'remote'.
-- Existing rows backfill to 'hybride' — most permissive default that doesn't
-- mislead either side: applicants can show interest knowing the spec was
-- never set, advertisers can sharpen later.
--
-- Idempotent: ADD COLUMN IF NOT EXISTS, safe to re-run per environment.

BEGIN;

ALTER TABLE public.services ADD COLUMN IF NOT EXISTS type_contrat varchar(20) NOT NULL DEFAULT 'hybride';
ALTER TABLE public.offres   ADD COLUMN IF NOT EXISTS type_contrat varchar(20) NOT NULL DEFAULT 'hybride';

CREATE INDEX IF NOT EXISTS idx_services_type_contrat ON public.services(type_contrat);
CREATE INDEX IF NOT EXISTS idx_offres_type_contrat   ON public.offres(type_contrat);

COMMIT;
