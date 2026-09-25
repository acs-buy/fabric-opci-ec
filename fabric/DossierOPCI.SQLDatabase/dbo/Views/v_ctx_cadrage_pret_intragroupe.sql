CREATE   VIEW dbo.v_ctx_cadrage_pret_intragroupe AS
SELECT t.* FROM dbo.v_ecran_cadrage_pret_intragroupe t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.arrete = t.arrete);

GO

