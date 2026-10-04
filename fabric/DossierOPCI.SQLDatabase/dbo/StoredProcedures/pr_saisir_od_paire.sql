

-- LES 2 LIGNES D'UNE ECRITURE, en une seule transaction. Les 2 sont controlees avant toute
-- ecriture : un refus de l'une n'ecrit aucune des 2, et son message dit de quelle ligne il vient.
CREATE   PROCEDURE dbo.pr_saisir_od_paire
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @compte1     VARCHAR (20),
    @libelle1    NVARCHAR (400),
    @debit1      DECIMAL (19, 2) = 0,
    @credit1     DECIMAL (19, 2) = 0,
    @piece_ref1  VARCHAR (50)    = NULL,
    @compte2     VARCHAR (20),
    @libelle2    NVARCHAR (400),
    @debit2      DECIMAL (19, 2) = 0,
    @credit2     DECIMAL (19, 2) = 0,
    @piece_ref2  VARCHAR (50)    = NULL,
    @reference   VARCHAR (20)    = NULL,
    @journal     VARCHAR (10)    = 'ODR',
    @par         NVARCHAR (400),
    @code_actif1 VARCHAR (20)    = NULL,
    @code_actif2 VARCHAR (20)    = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @qid INT, @cote VARCHAR (30), @fqid INT, @m NVARCHAR (2000), @n INT, @k INT = 1;
    WHILE @k <= 2
    BEGIN
        BEGIN TRY
            IF @k = 1
                EXEC dbo.pr_controler_ligne_od @entite, @arrete, @compte1, @debit1, @credit1, @reference, @journal, @qid OUTPUT, @cote OUTPUT, @fqid OUTPUT;
            ELSE
                EXEC dbo.pr_controler_ligne_od @entite, @arrete, @compte2, @debit2, @credit2, @reference, @journal, @qid OUTPUT, @cote OUTPUT, @fqid OUTPUT;
        END TRY
        BEGIN CATCH
            SELECT @n = ERROR_NUMBER(), @m = LEFT(N'Ligne ' + CAST(@k AS NVARCHAR (1)) + N' : ' + dbo.fn_sans_entete_ligne(ERROR_MESSAGE()), 2000);
            IF @n < 50000 THROW;
            THROW @n, @m, 1;
        END CATCH;
        SET @k += 1;
    END;
    BEGIN TRY
    BEGIN TRANSACTION;
    IF @reference IS NULL
        EXEC dbo.pr_assurer_feuille_od_libres @entite, @arrete, @par, @cote OUTPUT;
    INSERT INTO dbo.ecriture_brouillon (entite, arrete, feuille_cote, journal_code, compte_num, libelle, debit, credit, saisi_par,
                                        question_id, reference, code_actif, feuille_question_id)
    VALUES (@entite, @arrete, @cote, 'ODR', @compte1, @libelle1, ISNULL(@debit1, 0), ISNULL(@credit1, 0), @par, @qid, @piece_ref1, @code_actif1, @fqid),
           (@entite, @arrete, @cote, 'ODR', @compte2, @libelle2, ISNULL(@debit2, 0), ISNULL(@credit2, 0), @par, @qid, @piece_ref2, @code_actif2, @fqid);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @cote AS cote, N'Les 2 lignes sont enregistrées au brouillon.' AS message;
END;

GO

