CREATE   VIEW dbo.v_differences_titres AS
SELECT * FROM dbo.v_patrimoine_valorise WHERE famille = 'TITRE';

GO

