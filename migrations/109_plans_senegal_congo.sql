-- 109 — Plans d'abonnement pour le Sénégal et le Congo
--
-- Seul le Bénin avait des plans. On réplique les trois plans à l'identique —
-- mêmes libellés, mêmes descriptions, mêmes avantages, mêmes durées, même état
-- d'activation (mensuel et annuel actifs, trimestriel en réserve) — en
-- ajustant la seule chose qui change vraiment : la devise.
--
--   Sénégal → XOF, comme le Bénin (même zone UEMOA, mêmes prix).
--   Congo   → XAF (zone CEMAC). Le XAF vaut exactement le XOF — tous deux
--             adossés à l'euro à la même parité — donc les montants ne changent
--             pas ; seul le code de devise diffère.
--
-- Les identifiants store sont repris tels quels : le produit RevenueCat
-- (« com.edukia.app.premium.mensuel », « edukia_premium:mensuel »…) est le même
-- pour tous les pays. Le déclencheur d'unicité de la 106 vérifie l'unicité PAR
-- pays, donc le même identifiant peut coexister sur un plan par pays — c'est ce
-- qui permet à l'achat in-app d'un Sénégalais de retrouver SON plan.
--
-- Idempotent : on n'insère un plan que s'il n'existe pas déjà pour ce couple
-- (pays, code). Rejouer la migration ne crée pas de doublon.

BEGIN;

INSERT INTO public.plans_abonnement
    (pays, code, libelle, description, prix, devise, duree_jours, est_actif, ordre_affichage, avantages, identifiants_store)
SELECT v.pays, v.code, v.libelle, v.description, v.prix, v.devise, v.duree_jours, v.est_actif, v.ordre, v.avantages, v.identifiants_store
FROM (
    VALUES
    -- Sénégal (XOF)
    ('senegal', 'MENSUEL',     'Abonnement mensuel',     'Accès illimité pendant 1 mois',   2000::numeric,  'XOF', 30,  true,  1,
        ARRAY['Épreuves en illimité','Examens nationaux en illimité','Concours : téléchargement des sujets','Ketsia, l''assistante IA, sans limite'],
        ARRAY['com.edukia.app.premium.mensuel','edukia_premium:mensuel']),
    ('senegal', 'TRIMESTRIEL', 'Abonnement trimestriel', 'Accès illimité pendant 3 mois',   5000::numeric,  'XOF', 90,  false, 2,
        ARRAY['Épreuves en illimité','Examens nationaux en illimité','Concours : téléchargement des sujets','Ketsia, l''assistante IA, sans limite'],
        ARRAY['com.edukia.app.premium.trimestriel']),
    ('senegal', 'ANNUEL',      'Abonnement annuel',      'Accès illimité pendant 12 mois',  15000::numeric, 'XOF', 365, true,  3,
        ARRAY['Épreuves en illimité','Examens nationaux en illimité','Concours : téléchargement des sujets','Ketsia, l''assistante IA, sans limite'],
        ARRAY['com.edukia.app.premium.annuel','edukia_premium:annuel-12m']),
    -- Congo (XAF)
    ('congo',   'MENSUEL',     'Abonnement mensuel',     'Accès illimité pendant 1 mois',   2000::numeric,  'XAF', 30,  true,  1,
        ARRAY['Épreuves en illimité','Examens nationaux en illimité','Concours : téléchargement des sujets','Ketsia, l''assistante IA, sans limite'],
        ARRAY['com.edukia.app.premium.mensuel','edukia_premium:mensuel']),
    ('congo',   'TRIMESTRIEL', 'Abonnement trimestriel', 'Accès illimité pendant 3 mois',   5000::numeric,  'XAF', 90,  false, 2,
        ARRAY['Épreuves en illimité','Examens nationaux en illimité','Concours : téléchargement des sujets','Ketsia, l''assistante IA, sans limite'],
        ARRAY['com.edukia.app.premium.trimestriel']),
    ('congo',   'ANNUEL',      'Abonnement annuel',      'Accès illimité pendant 12 mois',  15000::numeric, 'XAF', 365, true,  3,
        ARRAY['Épreuves en illimité','Examens nationaux en illimité','Concours : téléchargement des sujets','Ketsia, l''assistante IA, sans limite'],
        ARRAY['com.edukia.app.premium.annuel','edukia_premium:annuel-12m'])
) AS v(pays, code, libelle, description, prix, devise, duree_jours, est_actif, ordre, avantages, identifiants_store)
WHERE NOT EXISTS (
    SELECT 1 FROM public.plans_abonnement p
     WHERE p.pays = v.pays AND p.code = v.code
);

COMMIT;
