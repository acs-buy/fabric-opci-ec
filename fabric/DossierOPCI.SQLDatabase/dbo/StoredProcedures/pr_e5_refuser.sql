-- ------------------------------------------------------------------ le refus : THROW du texte, « % » double
-- ecran 5
CREATE   PROCEDURE dbo.pr_e5_refuser @numero INT, @texte NVARCHAR (2000)
AS
BEGIN
    DECLARE @m NVARCHAR (4000) = REPLACE(@texte, N'%', N'%%');
    THROW @numero, @m, 1;
END;

GO

