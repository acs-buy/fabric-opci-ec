
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
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_compte WHERE compte = @compte)
       AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite WHERE entite = @entite AND compte_entite = @compte)
    BEGIN
        DECLARE @m1 NVARCHAR (400) = N'Le compte ' + @compte + N' n''est ni au plan OPCI ni au plan de l''entité.';
        THROW 50382, @m1, 1;
    END;
    IF @debit < 0 OR @credit < 0 OR (@debit > 0 AND @credit > 0)
        THROW 50383, N'Une ligne porte un débit OU un crédit, positif.', 1;
    DECLARE @qid INT = NULL, @cote VARCHAR (30), @fqid INT = NULL;
    IF @reference IS NOT NULL
    BEGIN
        SELECT @qid = q.id, @cote = fq.cote, @fqid = fq.id
        FROM dbo.ref_question q
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
        DECLARE @t TABLE (cote VARCHAR (30));
        INSERT INTO @t EXEC dbo.pr_ouvrir_od_libres @entite, @arrete, @par;
        SELECT @cote = cote FROM @t;
    END;
    INSERT INTO dbo.ecriture_brouillon (entite, arrete, feuille_cote, journal_code, compte_num, libelle, debit, credit, saisi_par,
                                        question_id, reference, code_actif, feuille_question_id)
    VALUES (@entite, @arrete, @cote, ISNULL(@journal, 'ODR'), @compte, @libelle, @debit, @credit, @par, @qid, @piece_ref, @code_actif, @fqid);
    SELECT SCOPE_IDENTITY() AS id, @cote AS cote, N'Ligne enregistrée au brouillon.' AS message;
END;

GO

