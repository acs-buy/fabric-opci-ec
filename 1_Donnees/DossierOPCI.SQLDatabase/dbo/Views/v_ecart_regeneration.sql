
-- --- 5 : B17, l'ecart de regeneration, ce que le bandeau lit -----------
-- Pour chaque intention en mode solde cible deja materialisee, l'ecart
-- entre la cible voulue et le solde tel qu'il est maintenant. Un ecart
-- non nul veut dire qu'une ecriture ulterieure a bouge le compte.
-- Un lot PROPOSE ne bouge pas la balance, critere A3 : son ecart vaut
-- alors la cible entiere, ce qui n'est pas un ecart mais une approbation
-- en attente. Les 3 etats se distinguent, sans quoi le bandeau crierait
-- a tort sur chaque intention non encore approuvee.
CREATE   VIEW dbo.v_ecart_regeneration AS
SELECT
    i.id AS intention_id, i.entite, i.arrete, i.feuille_cote,
    i.question_id, i.compte_num, i.compte_contrepartie, i.lot_id,
    l.statut AS statut_lot,
    i.solde_cible,
    CAST(COALESCE(b.balance_finale, 0) AS DECIMAL (19,2)) AS solde_actuel,
    CAST(i.solde_cible - COALESCE(b.balance_finale, 0) AS DECIMAL (19,2))
        AS ecart,
    CASE WHEN l.statut NOT IN ('VALIDE', 'EXPORTE', 'PUBLIE')
              THEN 'LOT_A_APPROUVER'
         WHEN i.solde_cible - COALESCE(b.balance_finale, 0) = 0
              THEN 'CIBLE_ATTEINTE'
         ELSE 'ECART_A_VISER' END AS statut,
    CASE WHEN l.statut NOT IN ('VALIDE', 'EXPORTE', 'PUBLIE')
              THEN N'Le lot ' + CAST(i.lot_id AS NVARCHAR (12))
                 + N' est propose : il ne bouge pas la balance tant qu''il '
                 + N'n''est pas approuve. Aucun ecart n''est constatable.'
         WHEN i.solde_cible - COALESCE(b.balance_finale, 0) <> 0
              THEN N'Le solde du compte ' + i.compte_num + N' a bouge depuis '
                 + N'la generation : la cible n''est plus atteinte. Viser '
                 + N'l''ecart ou poser une nouvelle intention.' END AS message
FROM dbo.intention_ecriture i
JOIN dbo.lot_ecritures l ON l.id = i.lot_id
LEFT JOIN dbo.v_balance b
       ON b.arrete = i.arrete AND b.entite = i.entite
      AND b.compte = i.compte_num
WHERE i.mode = 'SOLDE_CIBLE' AND i.lot_id IS NOT NULL;

GO

