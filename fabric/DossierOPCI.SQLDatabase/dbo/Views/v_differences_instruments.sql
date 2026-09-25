CREATE   VIEW dbo.v_differences_instruments AS
SELECT * FROM dbo.v_patrimoine_valorise WHERE famille = 'INSTRUMENT';

GO

