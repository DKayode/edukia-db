-- 106 — Rattacher un plan aux identifiants produit des stores
--
-- Un achat in-app est encaissé par Apple ou Google, pas par nous. RevenueCat
-- nous le notifie avec un `product_id` — « com.edukia.app.premium.annuel » —
-- et rien ne permettait de savoir à quel plan il correspond.
--
-- Une LISTE plutôt qu'une colonne simple : un même plan porte souvent un
-- identifiant par store, et il en change au fil des versions de l'application
-- sans que l'offre change.
--
-- Semé d'après la convention observée dans les webhooks reçus : le suffixe de
-- l'identifiant reprend le code du plan en minuscules. À corriger depuis le
-- back-office si App Store et Play Store divergent.

BEGIN;

ALTER TABLE public.plans_abonnement
    ADD COLUMN IF NOT EXISTS identifiants_store text[] NULL;

COMMENT ON COLUMN public.plans_abonnement.identifiants_store IS
    'Identifiants produit App Store / Play Store rattachés à ce plan. '
    'NULL ou vide : aucun achat in-app ne peut être rattaché à ce plan.';

UPDATE public.plans_abonnement
   SET identifiants_store = ARRAY['com.edukia.app.premium.' || lower(code)]
 WHERE identifiants_store IS NULL OR cardinality(identifiants_store) = 0;

-- Un identifiant produit ne doit désigner qu'un seul plan par pays, sans quoi
-- un webhook serait rattaché arbitrairement à l'un ou l'autre. Postgres ne sait
-- pas indexer l'unicité des ÉLÉMENTS d'un tableau ; on la fait donc respecter
-- par un déclencheur, qui refuse un chevauchement à l'écriture.
CREATE OR REPLACE FUNCTION public.verifier_unicite_identifiants_store()
RETURNS trigger AS $$
DECLARE conflit text;
BEGIN
    IF NEW.identifiants_store IS NULL OR cardinality(NEW.identifiants_store) = 0 THEN
        RETURN NEW;
    END IF;
    SELECT p.code INTO conflit
      FROM public.plans_abonnement p
     WHERE p.pays = NEW.pays
       AND p.id <> COALESCE(NEW.id, -1)
       AND p.identifiants_store && NEW.identifiants_store
     LIMIT 1;
    IF conflit IS NOT NULL THEN
        RAISE EXCEPTION 'Identifiant produit déjà rattaché au plan % (%)', conflit, NEW.pays;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_unicite_identifiants_store ON public.plans_abonnement;
CREATE TRIGGER trg_unicite_identifiants_store
    BEFORE INSERT OR UPDATE OF identifiants_store, pays ON public.plans_abonnement
    FOR EACH ROW EXECUTE FUNCTION public.verifier_unicite_identifiants_store();

COMMIT;
