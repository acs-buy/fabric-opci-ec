CREATE   VIEW dbo.v_differences_comptes_courants AS
SELECT * FROM dbo.v_patrimoine_valorise WHERE famille = 'COMPTE_COURANT';

GO

