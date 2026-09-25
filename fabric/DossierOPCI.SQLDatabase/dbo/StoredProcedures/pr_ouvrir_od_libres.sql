
-- --- 3. les OD : une ligne, un classeur, la validation des OD libres ----------------------------------
CREATE   PROCEDURE dbo.pr_ouvrir_od_libres
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50381, N'Les OD libres se saisissent sur un arrêté ouvert.', 1;
    DECLARE @cote VARCHAR (30) = 'ODL-' + LEFT(@entite, 15) + '-' + REPLACE(@arrete, '-', '');
    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
        INSERT INTO dbo.feuille_travail (cote, cycle, phase, arrete, entite, modele_code, origine, nom_fichier, chemin_coffre,
                                         empreinte_sha256, preparateur, prepare_le)
        VALUES (@cote, NULL, 'COMPTES', @arrete, @entite, NULL, 'HUMAINE',
                N'od_libres_' + @entite + N'_' + @arrete + N'.xlsx', N'/Coffre/' + @entite + N'/' + @arrete + N'/od/od_libres.xlsx',
                CONVERT(CHAR (64), HASHBYTES('SHA2_256', CONVERT(NVARCHAR (100), @cote)), 2), @par, SYSUTCDATETIME());
    SELECT @cote AS cote;
END;

GO

