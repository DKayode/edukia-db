-- Ouvre les numéros Mobile Money au Sénégal (+221) et au Congo-Brazzaville
-- (+242), en plus du Bénin (+229).
--
-- Deux contraintes CHECK figeaient l'indicatif béninois. Le code applicatif a
-- beau accepter les trois pays, l'insertion partait en erreur 500 : la
-- validation applicative et la base ne disaient pas la même chose.
--
-- Formats retenus, sur le numéro compacté (espaces, points et tirets retirés) :
--   Bénin    +229 01 + 8 chiffres   (numérotation à 10 chiffres depuis 2023)
--   Sénégal  +221 7X + 7 chiffres   (mobiles 70, 75, 76, 77, 78)
--   Congo    +242 0X + 7 chiffres   (mobiles 04, 05, 06)
--
-- Les contraintes restent NOT VALID, comme les précédentes : elles s'appliquent
-- aux écritures futures sans imposer un contrôle des lignes existantes. Toutes
-- les lignes actuelles sont béninoises et satisfont de toute façon la nouvelle
-- version, strictement plus permissive que l'ancienne.
--
-- Les noms de contrainte perdent « benin » : ils décrivaient une règle qui
-- n'existe plus.
BEGIN;

ALTER TABLE user_payment_accounts
    DROP CONSTRAINT IF EXISTS chk_user_payment_accounts_benin_phone;
ALTER TABLE user_payment_accounts
    DROP CONSTRAINT IF EXISTS chk_user_payment_accounts_momo_phone;
ALTER TABLE user_payment_accounts
    ADD CONSTRAINT chk_user_payment_accounts_momo_phone
    CHECK (
        regexp_replace(phone_number, '[[:space:].-]', '', 'g')
        ~ '^\+(22901[0-9]{8}|2217[05678][0-9]{7}|2420[456][0-9]{7})$'
    ) NOT VALID;

ALTER TABLE payment_executions
    DROP CONSTRAINT IF EXISTS chk_payment_executions_benin_phone;
ALTER TABLE payment_executions
    DROP CONSTRAINT IF EXISTS chk_payment_executions_momo_phone;
ALTER TABLE payment_executions
    ADD CONSTRAINT chk_payment_executions_momo_phone
    CHECK (
        regexp_replace(phone_number, '[[:space:].-]', '', 'g')
        ~ '^\+(22901[0-9]{8}|2217[05678][0-9]{7}|2420[456][0-9]{7})$'
    ) NOT VALID;

COMMIT;
