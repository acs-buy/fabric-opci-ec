-- ------------------------------------------------------------------ le refus : THROW du texte, « % » double
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   PROCEDURE dbo.pr_e5_refuser @numero INT, @texte NVARCHAR (2000)
AS
BEGIN
    DECLARE @m NVARCHAR (4000) = REPLACE(@texte, N'%', N'%%');
    THROW @numero, @m, 1;
END;

GO

