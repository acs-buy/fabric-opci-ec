
-- Le classeur d'OD d'une question, ou des OD libres : ses lignes REMPLACENT le brouillon courant du meme
-- perimetre. @lignes : [{"journal":"ODR","compte":"213","libelle":"...","debit":100,"credit":0,"piece":"...","actif":"IMM-201"}]
CREATE   PROCEDURE dbo.pr_importer_od
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @reference  VARCHAR (20)   = NULL,
    @lignes     NVARCHAR (MAX),
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF ISJSON(@lignes) <> 1
        THROW 50385, N'Le contenu reçu n''est pas un tableau de lignes lisible.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @t TABLE (rang INT IDENTITY (1, 1), journal VARCHAR (10), compte VARCHAR (20), libelle NVARCHAR (400),
                      debit DECIMAL (19, 2), credit DECIMAL (19, 2), piece VARCHAR (50), actif VARCHAR (20));
    INSERT INTO @t (journal, compte, libelle, debit, credit, piece, actif)
    SELECT ISNULL(journal, 'ODR'), compte, libelle, ISNULL(debit, 0), ISNULL(credit, 0), piece, actif
    FROM OPENJSON(@lignes) WITH (journal VARCHAR (10) '$.journal', compte VARCHAR (20) '$.compte', libelle NVARCHAR (400) '$.libelle',
                                debit DECIMAL (19, 2) '$.debit', credit DECIMAL (19, 2) '$.credit', piece VARCHAR (50) '$.piece', actif VARCHAR (20) '$.actif')
    WHERE compte IS NOT NULL;
    DECLARE @n INT = (SELECT COUNT(*) FROM @t);

    DECLARE @qid INT = NULL, @cote VARCHAR (30);
    IF @reference IS NOT NULL
    BEGIN
        SELECT @qid = q.id, @cote = fq.cote FROM dbo.ref_question q
        JOIN dbo.feuille_question fq ON fq.question_id = q.id
        JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.entite = @entite AND f.arrete = @arrete AND f.cote LIKE 'Q-%'
        WHERE q.reference = @reference;
        IF @qid IS NULL
        BEGIN
            DECLARE @m2 NVARCHAR (400) = N'La question ' + @reference + N' n''est pas au programme de cet arrêté.';
            THROW 50384, @m2, 1;
        END;
    END
    ELSE
    BEGIN
        DECLARE @c TABLE (cote VARCHAR (30));
        INSERT INTO @c EXEC dbo.pr_ouvrir_od_libres @entite, @arrete, @par;
        SELECT @cote = cote FROM @c;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    DELETE dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote
       AND ((@qid IS NULL AND question_id IS NULL) OR question_id = @qid);
    DECLARE @i INT = 1, @j VARCHAR (10), @co VARCHAR (20), @li NVARCHAR (400), @d DECIMAL (19, 2), @cr DECIMAL (19, 2), @pi VARCHAR (50), @ac VARCHAR (20);
    WHILE @i <= @n
    BEGIN
        SELECT @j = journal, @co = compte, @li = libelle, @d = debit, @cr = credit, @pi = piece, @ac = actif FROM @t WHERE rang = @i;
        EXEC dbo.pr_saisir_od @entite, @arrete, @co, @li, @d, @cr, @reference, @j, @pi, @ac, @par;
        SET @i += 1;
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    DECLARE @sd DECIMAL (19, 2), @sc DECIMAL (19, 2);
    SELECT @sd = ISNULL(SUM(debit), 0), @sc = ISNULL(SUM(credit), 0) FROM dbo.ecriture_brouillon
     WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND ((@qid IS NULL AND question_id IS NULL) OR question_id = @qid);
    SELECT @cote AS cote, @n AS lignes, @sd AS debit, @sc AS credit,
           CAST(@n AS NVARCHAR (10)) + N' ligne(s) d''OD au brouillon' + CASE WHEN @reference IS NOT NULL THEN N' de la question ' + @reference ELSE N' libres' END
         + CASE WHEN @sd <> @sc THEN N'. Déséquilibre de ' + FORMAT(@sd - @sc, 'N2', 'fr-FR') + N' : la validation le refusera.' ELSE N', équilibrées.' END AS message;
END;

GO

