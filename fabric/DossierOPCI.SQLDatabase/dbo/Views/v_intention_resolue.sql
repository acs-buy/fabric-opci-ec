
-- --- 2 : la resolution d'une intention, une seule source pour le solde --
-- Le solde actuel vient de v_balance.balance_finale, jamais d'un calcul
-- refait ici. Une intention en mode PAR_LIGNE rend son montant tel quel.
CREATE   VIEW dbo.v_intention_resolue AS
SELECT
    i.id, i.entite, i.arrete, i.feuille_cote, i.question_id, i.mode,
    i.compte_num, i.compte_contrepartie, i.libelle, i.lot_id,
    i.solde_cible,
    CAST(COALESCE(b.balance_finale, 0) AS DECIMAL (19,2)) AS solde_actuel,
    -- Le montant a ecrire, dans les 2 modes.
    CAST(CASE WHEN i.mode = 'PAR_LIGNE' THEN i.montant
              ELSE ABS(i.solde_cible - COALESCE(b.balance_finale, 0))
         END AS DECIMAL (19,2)) AS montant_resolu,
    -- Le sens a ecrire. Un solde s'entend debit moins credit : atteindre
    -- une cible superieure au solde actuel se fait au debit.
    CAST(CASE WHEN i.mode = 'PAR_LIGNE' THEN i.sens
              WHEN i.solde_cible - COALESCE(b.balance_finale, 0) > 0
                   THEN 'DEBIT'
              WHEN i.solde_cible - COALESCE(b.balance_finale, 0) < 0
                   THEN 'CREDIT'
              ELSE NULL
         END AS VARCHAR (6)) AS sens_resolu
FROM dbo.intention_ecriture i
LEFT JOIN dbo.v_balance b
       ON b.arrete = i.arrete AND b.entite = i.entite
      AND b.compte = i.compte_num;

GO

