
-- pr_saisir_od_paire : 1 refus
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
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51215, N'Choisissez l''arrêté dans le sélecteur Arrêté ; les OD libres ne se modifient que sur un arrêté ouvert dont le dossier de travail n''est pas verrouillé.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @compte1 COLLATE Latin1_General_100_BIN2)), 0) = 0 AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @libelle1 COLLATE Latin1_General_100_BIN2)), 0) = 0 AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @compte2 COLLATE Latin1_General_100_BIN2)), 0) = 0 AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @libelle2 COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51235, N'Aucun compte saisi : une écriture porte au moins une ligne.', 1;
    DECLARE @r327_saisies NVARCHAR (400) = CONCAT(
        CASE WHEN ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @compte1 COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN N', « Compte de la ligne 1 »' END,
        CASE WHEN ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @libelle1 COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN N', « Libellé de la ligne 1 »' END,
        CASE WHEN ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @compte2 COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN N', « Compte de la ligne 2 »' END,
        CASE WHEN ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @libelle2 COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN N', « Libellé de la ligne 2 »' END);
    IF @r327_saisies <> N''
    BEGIN
        SET @r327_saisies = N'Champs obligatoires à remplir : ' + STUFF(@r327_saisies, 1, 2, N'') + N'.';
        THROW 51220, @r327_saisies, 1;
    END;
    -- 327 fin
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
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW @n, @m, 1; END
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

