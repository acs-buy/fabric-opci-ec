
-- C86 : un compte de charges ou de produits qui ne ressort pas a zero
-- apres la determination du resultat. C'est le SYMPTOME direct d'une
-- ventilation fausse, et il vaut mieux que le compte des parts : une
-- ecriture de solde deja scindee porte plusieurs parts sans que rien ne
-- soit faux, et la premiere redaction de ce controle les signalait
-- toutes, 48 apres la traduction des 12 filiales, alors qu'aucun solde
-- ne subsistait.
CREATE   VIEW dbo.v_controle_solde_mal_ventile AS
SELECT l.entite, l.arrete, e.compte_num,
       SUM(e.debit) - SUM(e.credit)                    AS solde_residuel,
       N'ce compte de charges ou de produits ne ressort pas à zéro après la détermination du résultat : l''écriture de solde ne suit pas la ventilation de ce qu''elle solde'
                                                       AS lecture
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND (e.compte_num LIKE '6%' OR e.compte_num LIKE '7%')
  AND EXISTS (SELECT 1 FROM dbo.ecriture z
              JOIN dbo.lot_ecritures y ON y.id = z.lot_id
              WHERE y.entite = l.entite AND y.arrete = l.arrete
                AND z.ecriture_num = 'DET')
GROUP BY l.entite, l.arrete, e.compte_num
HAVING SUM(e.debit) - SUM(e.credit) <> 0

GO

