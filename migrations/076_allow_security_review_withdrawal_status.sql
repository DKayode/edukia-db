-- Autorise les deux statuts de retrait que le code écrit mais que la base
-- refusait : SECURITY_REVIEW_REQUIRED et OTP_EXPIRED.
--
-- L'énumération applicative compte dix statuts, la contrainte n'en acceptait
-- que huit. Toute tentative d'écrire les deux manquants échouait, non pas avec
-- une erreur métier, mais avec une violation de contrainte remontée en 500.
--
-- Ce n'était pas théorique. Deux chemins mènent à SECURITY_REVIEW_REQUIRED :
--
--   1. trois codes OTP erronés à la saisie (verify-withdrawal-otp) ;
--   2. le nombre maximal de renvois atteint (resend-withdrawal-otp).
--
-- Dans les deux cas l'OTP est d'abord verrouillé — cette écriture-là passe —
-- puis la mise à jour du retrait échoue. L'utilisateur reçoit un 500 au lieu du
-- message « une vérification administrateur est nécessaire », les
-- administrateurs ne sont jamais alertés, et la demande reste en OTP_PENDING :
-- elle bloque toute nouvelle demande sans que personne ne soit prévenu.
--
-- Relevé le 19 août 2026 : aucune demande n'avait jamais atteint ce statut en
-- production, et deux utilisateurs étaient bloqués — l'un depuis le 7 août.
--
-- OTP_EXPIRED n'est aujourd'hui écrit par aucun code, mais il figure dans la
-- même énumération : l'ajouter maintenant évite de rejouer exactement la même
-- panne le jour où quelqu'un s'en servira.
BEGIN;

ALTER TABLE withdrawal_requests
    DROP CONSTRAINT IF EXISTS withdrawal_requests_status_check;

ALTER TABLE withdrawal_requests
    ADD CONSTRAINT withdrawal_requests_status_check
    CHECK (status IN (
        'OTP_PENDING',
        'PENDING',
        'APPROVED',
        'PROCESSING',
        'PAID',
        'FAILED',
        'REJECTED',
        'CANCELLED',
        'SECURITY_REVIEW_REQUIRED',
        'OTP_EXPIRED'
    ));

COMMIT;
