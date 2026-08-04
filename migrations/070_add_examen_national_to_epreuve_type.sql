-- Add "Examens Nationaux" to the epreuves.type enum so it can be selected as an
-- épreuve type in the dashboard (alongside Interrogation/Devoirs/Concours/Examens).
-- Idempotent via IF NOT EXISTS. NOT wrapped in a transaction: on older Postgres
-- ALTER TYPE ... ADD VALUE cannot run inside a transaction block.
ALTER TYPE "epreuves_type_enum" ADD VALUE IF NOT EXISTS 'Examens Nationaux';
