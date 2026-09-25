
CREATE   PROCEDURE dbo.pr_modifier_filiale
    @client         VARCHAR (20),
    @code           VARCHAR (20),
    @denomination   NVARCHAR (400) = NULL,   -- vide = inchange
    @forme_sociale  VARCHAR (10)   = NULL,   -- vide = inchange
    @droits_de_vote DECIMAL (9, 6) = NULL,   -- vide = inchange
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_mere = @client AND entite_fille = @code)
        THROW 50216, N'Cette entité n''est pas une filiale de ce client. Le code d''une filiale ne se modifie pas.', 1;
    IF @droits_de_vote IS NOT NULL AND (@droits_de_vote <= 0 OR @droits_de_vote > 1)
        THROW 50213, N'Les droits de vote se donnent entre 0 et 1, par exemple 0,80 pour 80 %.', 1;
    SET @denomination = NULLIF(LTRIM(RTRIM(@denomination)), N'');
    SET @forme_sociale = NULLIF(LTRIM(RTRIM(@forme_sociale)), '');
    IF @denomination IS NULL AND @forme_sociale IS NULL AND @droits_de_vote IS NULL
        THROW 50217, N'Rien à modifier : renseignez au moins un champ.', 1;

    DECLARE @detail NVARCHAR (800) = N'';
    BEGIN TRY
    BEGIN TRANSACTION;
    IF @denomination IS NOT NULL OR @forme_sociale IS NOT NULL
    BEGIN
        UPDATE e SET denomination = COALESCE(@denomination, e.denomination),
                     forme_sociale = COALESCE(@forme_sociale, e.forme_sociale),
                     modifie_par = @par, modifie_le = SYSUTCDATETIME()
          FROM dbo.ref_entite e WHERE e.code = @code;
        SET @detail += CASE WHEN @denomination IS NOT NULL THEN N'dénomination → ' + @denomination + N' ; ' ELSE N'' END
                     + CASE WHEN @forme_sociale IS NOT NULL THEN N'forme → ' + @forme_sociale + N' ; ' ELSE N'' END;
    END;
    IF @droits_de_vote IS NOT NULL
    BEGIN
        UPDATE dbo.eligibilite_participation SET droits_de_vote = @droits_de_vote, qualifie_par = @par, qualifie_le = SYSUTCDATETIME()
         WHERE entite_mere = @client AND entite_fille = @code;
        SET @detail += N'droits de vote → ' + FORMAT(@droits_de_vote, 'P2', 'fr-FR') + N' ; ';
    END;
    INSERT INTO dbo.journal_perimetre (entite_mere, entite_fille, action, detail, fait_par)
    VALUES (@client, @code, 'MODIFICATION', LEFT(@detail, 800), @par);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @code AS filiale, N'Filiale ' + @code + N' mise à jour : ' + LEFT(@detail, LEN(@detail) - 2) + N'.' AS message;
END;

GO

