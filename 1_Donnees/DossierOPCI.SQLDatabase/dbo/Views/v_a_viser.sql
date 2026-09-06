CREATE   VIEW dbo.v_a_viser AS
SELECT * FROM dbo.v_a_viser_lot
UNION ALL SELECT * FROM dbo.v_a_viser_conclusion
UNION ALL SELECT * FROM dbo.v_a_viser_derogation
UNION ALL SELECT * FROM dbo.v_a_viser_ecart
UNION ALL SELECT * FROM dbo.v_a_viser_publication;

GO

