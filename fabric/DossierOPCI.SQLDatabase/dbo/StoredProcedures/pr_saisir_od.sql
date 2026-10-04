
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

