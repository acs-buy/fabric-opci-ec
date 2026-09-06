-- Un referentiel inscrit qui n'existe pas en base est une erreur de
-- cette liste, non de la base. ATTENDU zero.
CREATE   VIEW dbo.v_controle_referentiel_absent AS
SELECT r.table_nom, r.libelle
FROM dbo.ref_referentiel r
WHERE NOT EXISTS (SELECT 1 FROM sys.tables t WHERE t.name = r.table_nom);

GO

