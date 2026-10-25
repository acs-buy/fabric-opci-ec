
CREATE   PROCEDURE dbo.pr_saisir_od
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @compte     VARCHAR (20),
    @libelle    NVARCHAR (400),
    @debit      DECIMAL (19, 2) = 0,
    @credit     DECIMAL (19, 2) = 0,
    @reference  VARCHAR (20)    = NULL,     -- la question, pour une OD liee ; NULL pour une OD libre
    @journal    VARCHAR (10)    = 'ODR',
    @piece_ref  VARCHAR (50)    = NULL,
    @code_actif VARCHAR (20)    = NULL,
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
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
    DECLARE @r327_saisies NVARCHAR (400) = CONCAT(
        CASE WHEN ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @compte COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN N', « Compte »' END,
        CASE WHEN ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @libelle COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN N', « Libellé »' END);
    IF @r327_saisies <> N''
    BEGIN
        SET @r327_saisies = N'Champs obligatoires à remplir : ' + STUFF(@r327_saisies, 1, 2, N'') + N'.';
        THROW 51219, @r327_saisies, 1;
    END;
    -- 327 fin
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    DECLARE @qid INT, @cote VARCHAR (30), @fqid INT;
    EXEC dbo.pr_controler_ligne_od @entite, @arrete, @compte, @debit, @credit, @reference, @journal, @qid OUTPUT, @cote OUTPUT, @fqid OUTPUT;
    IF @reference IS NULL
        EXEC dbo.pr_assurer_feuille_od_libres @entite, @arrete, @par, @cote OUTPUT;
    INSERT INTO dbo.ecriture_brouillon (entite, arrete, feuille_cote, journal_code, compte_num, libelle, debit, credit, saisi_par,
                                        question_id, reference, code_actif, feuille_question_id)
    VALUES (@entite, @arrete, @cote, 'ODR', @compte, @libelle, ISNULL(@debit, 0), ISNULL(@credit, 0), @par, @qid, @piece_ref, @code_actif, @fqid);
    SELECT SCOPE_IDENTITY() AS id, @cote AS cote, N'Ligne enregistrée au brouillon.' AS message;
END;

GO

