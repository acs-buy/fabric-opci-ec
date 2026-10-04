
-- --- 3. les OD : une ligne, un classeur, la validation des OD libres ----------------------------------
CREATE   PROCEDURE dbo.pr_ouvrir_od_libres
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @cote VARCHAR (30);
    EXEC dbo.pr_assurer_feuille_od_libres @entite, @arrete, @par, @cote OUTPUT;
    SELECT @cote AS cote;
END;

GO

