
CREATE   VIEW dbo.v_comptes_en_balance AS
SELECT DISTINCT l.entite, l.arrete, e.compte_num AS compte
FROM dbo.lot_ecritures l
JOIN dbo.ecriture e ON e.lot_id = l.id
WHERE l.statut <> 'REJETE';

GO

