-- Correctif edukia#246 : une commission reprise après remboursement est
-- enregistrée comme un ajustement négatif dans le grand livre du wallet.
-- Les crédits, libérations et retraits conservent leur contrainte positive.
BEGIN;

ALTER TABLE public.wallet_transactions
  DROP CONSTRAINT IF EXISTS wallet_transactions_amount_check;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1
      FROM pg_constraint
     WHERE conrelid = 'public.wallet_transactions'::regclass
       AND conname = 'chk_wallet_transactions_amount'
  ) THEN
    ALTER TABLE public.wallet_transactions
      ADD CONSTRAINT chk_wallet_transactions_amount
      CHECK (
        (type = 'ADJUSTMENT' AND amount <> 0)
        OR (type <> 'ADJUSTMENT' AND amount > 0)
      );
  END IF;
END $$;

COMMENT ON CONSTRAINT chk_wallet_transactions_amount ON public.wallet_transactions IS
  'Les ajustements peuvent être signés; les autres transactions sont strictement positives.';

COMMIT;
