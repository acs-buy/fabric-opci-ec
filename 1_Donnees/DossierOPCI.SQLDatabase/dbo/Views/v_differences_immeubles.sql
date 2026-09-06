
-- --- 5 : les 4 vues par famille et les controles, refaites ----------
CREATE   VIEW dbo.v_differences_immeubles AS
SELECT * FROM dbo.v_patrimoine_valorise WHERE famille = 'IMMEUBLE';

GO

