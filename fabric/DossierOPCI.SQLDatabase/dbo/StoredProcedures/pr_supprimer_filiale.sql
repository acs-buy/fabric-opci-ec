
CREATE   PROCEDURE dbo.pr_supprimer_filiale
    @client   VARCHAR (20),
    @code     VARCHAR (20),
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_mere = @client AND entite_fille = @code)
        THROW 50216, N'Cette entité n''est pas une filiale de ce client.', 1;

    DECLARE @arretes INT, @feuilles INT, @pieces INT, @ecritures INT, @comptes INT, @detentions INT, @supprimable BIT, @denomination NVARCHAR (400);
    SELECT @arretes = arretes, @feuilles = feuilles, @pieces = pieces, @ecritures = ecritures, @comptes = comptes,
           @detentions = detentions, @supprimable = supprimable, @denomination = denomination
      FROM dbo.v_filiale_dependances WHERE entite_mere = @client AND entite_fille = @code;
    IF @supprimable = 0
    BEGIN
        DECLARE @m NVARCHAR (1000) = N'La filiale ' + @code + N' porte des données de mission et ne se supprime pas : '
            + CASE WHEN @arretes > 0 THEN CAST(@arretes AS NVARCHAR (10)) + N' arrêté(s), ' ELSE N'' END
            + CASE WHEN @feuilles > 0 THEN CAST(@feuilles AS NVARCHAR (10)) + N' feuille(s), ' ELSE N'' END
            + CASE WHEN @pieces > 0 THEN CAST(@pieces AS NVARCHAR (10)) + N' pièce(s), ' ELSE N'' END
            + CASE WHEN @ecritures > 0 THEN CAST(@ecritures AS NVARCHAR (10)) + N' écriture(s) ou import(s), ' ELSE N'' END
            + CASE WHEN @comptes > 0 THEN CAST(@comptes AS NVARCHAR (10)) + N' compte(s), ' ELSE N'' END
            + CASE WHEN @detentions > 0 THEN CAST(@detentions AS NVARCHAR (10)) + N' détention(s) à un arrêté, ' ELSE N'' END;
        SET @m = LEFT(@m, LEN(@m) - 1) + N'. Sa sortie du groupe se constate par la détention à l''arrêté suivant.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_supprimer_filiale', @code, NULL, @m, N'Constater la sortie par la détention, ne pas supprimer.', @par, SYSUTCDATETIME());
        THROW 50218, @m, 1;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    DELETE dbo.role_mission WHERE entite = @code;
    DELETE dbo.demande_espace_client WHERE entite = @code;
    DELETE dbo.eligibilite_participation WHERE entite_mere = @client AND entite_fille = @code;
    -- la ligne d'entite part si aucun autre client ne la detient
    IF NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_fille = @code)
        DELETE dbo.ref_entite WHERE code = @code AND est_client = 0;
    INSERT INTO dbo.journal_perimetre (entite_mere, entite_fille, action, detail, fait_par)
    VALUES (@client, @code, 'SUPPRESSION', N'retirée du périmètre ; ' + @denomination, @par);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @code AS filiale, N'Filiale ' + @code + N' (' + @denomination + N') retirée du périmètre de ' + @client + N'.' AS message;
END;

GO

