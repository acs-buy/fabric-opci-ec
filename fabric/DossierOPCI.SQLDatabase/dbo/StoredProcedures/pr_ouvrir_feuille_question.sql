
CREATE   PROCEDURE dbo.pr_ouvrir_feuille_question
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @reference  VARCHAR (20),
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @qid INT, @cycle VARCHAR (10);
    SELECT @qid = id, @cycle = cycle FROM dbo.ref_question WHERE reference = @reference;
    IF @qid IS NULL OR @cycle IS NULL
        THROW 50361, N'La question désignée n''est pas une question de cycle du référentiel.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @cote VARCHAR (30) = (SELECT TOP 1 cote FROM dbo.feuille_travail
                                  WHERE entite = @entite AND arrete = @arrete AND question_id = @qid ORDER BY prepare_le DESC);
    IF @cote IS NOT NULL
    BEGIN
        SELECT @cote AS cote, N'La feuille ' + @cote + N' est déjà ouverte pour la question ' + @reference + N'.' AS message;
        RETURN;
    END;
    DECLARE @modele VARCHAR (20) = ISNULL((SELECT TOP 1 modele_code FROM dbo.ref_question_modele WHERE question_id = @qid ORDER BY modele_code), 'STD');
    SET @cote = LEFT('FT-' + @reference + '-' + REPLACE(@arrete, '-', ''), 30);
    EXEC dbo.pr_ouvrir_feuille @cote, @modele, @entite, @arrete, @cycle, NULL, @par;
    UPDATE dbo.feuille_travail SET question_id = @qid WHERE cote = @cote;
    SELECT @cote AS cote, @modele AS modele,
           N'Feuille ' + @cote + N' ouverte pour la question ' + @reference + N', gabarit ' + @modele + N'. Exportez-la, remplissez-la, redéposez-la.' AS message;
END;

GO

