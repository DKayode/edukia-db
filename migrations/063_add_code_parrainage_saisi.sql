-- 063: persist the referral code the user typed at signup, even when it
-- matches no existing user (parrain_id stays null). Distinct from
-- mon_code_parrainage, which is the user's OWN generated code.
ALTER TABLE utilisateurs
  ADD COLUMN IF NOT EXISTS code_parrainage_saisi varchar;

-- Backfill existing rows: a user with a resolved parrain_id necessarily
-- typed that parrain's own code, so recover it. Users who typed an
-- invalid code (parrain_id null) never had it stored — unrecoverable,
-- left null. Idempotent: only fills rows still null.
UPDATE utilisateurs u
SET code_parrainage_saisi = p.mon_code_parrainage
FROM utilisateurs p
WHERE u.parrain_id = p.id
  AND u.code_parrainage_saisi IS NULL;
