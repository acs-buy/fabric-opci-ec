
-- --- 2. l'import d'une feuille remplie : conclusion, forme, fichier -----------------------------------
CREATE   PROCEDURE dbo.pr_importer_feuille
    @cote         VARCHAR (30),
    @conclusion   NVARCHAR (800)  = NULL,
    @forme        VARCHAR (20)    = NULL,        -- SANS_OBSERVATION, AVEC_OBSERVATION, REFUS_ATTESTER : conclut la feuille
    @nom_fichier  NVARCHAR (400)  = NULL,
    @empreinte    CHAR (64)       = NULL,
    @par          NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @conclue DATETIME2 (3);
    SELECT @entite = entite, @arrete = arrete, @conclue = conclue_le FROM dbo.feuille_travail WHERE cote = @cote;
    IF @entite IS NULL
        THROW 50371, N'La feuille désignée n''existe pas.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    IF @conclue IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.visa WHERE nature = 'CONCLUSION' AND objet_ref = @cote AND decision = 'VISE')
        THROW 50372, N'Cette feuille est conclue et visée ; elle ne se modifie plus.', 1;
    IF @forme IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_forme_conclusion WHERE code = @forme)
        THROW 50373, N'La forme de conclusion est SANS_OBSERVATION, AVEC_OBSERVATION ou REFUS_ATTESTER.', 1;
    -- texte et forme entrent ensemble ou pas du tout : une porte de la conclusion (pieces du cycle, derogation)
    -- qui refuse la forme ne laisse pas un texte orphelin
    BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE dbo.feuille_travail
       SET conclusion = COALESCE(@conclusion, conclusion),
           nom_fichier = COALESCE(@nom_fichier, nom_fichier),
           empreinte_sha256 = COALESCE(@empreinte, empreinte_sha256)
     WHERE cote = @cote;
    IF @forme IS NOT NULL
        EXEC dbo.pr_conclure_feuille @cote, @forme, @par;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @cote AS cote,
           N'Feuille ' + @cote + N' reprise' + CASE WHEN @forme IS NOT NULL THEN N' et conclue (' + @forme + N')' ELSE N'' END + N'.' AS message;
END;

GO

