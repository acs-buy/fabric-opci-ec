
-- LES CONTROLES D'UNE LIGNE D'OD, sans resultat ni ecriture. Rend la question et sa feuille.
CREATE   PROCEDURE dbo.pr_controler_ligne_od
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @compte     VARCHAR (20),
    @debit      DECIMAL (19, 2),
    @credit     DECIMAL (19, 2),
    @reference  VARCHAR (20),
    @journal    VARCHAR (10),
    @qid        INT OUTPUT,
    @cote_q     VARCHAR (30) OUTPUT,
    @fqid       INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @m NVARCHAR (400);
    IF NULLIF(LTRIM(RTRIM(@journal)), '') IS NOT NULL AND LTRIM(RTRIM(@journal)) <> 'ODR'
    BEGIN
        SET @m = N'Ligne refusée : les OD de révision se passent au journal ODR ; le journal « ' + LTRIM(RTRIM(@journal)) + N' » n''est pas admis.';
        THROW 50402, @m, 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_compte WHERE compte = @compte)
       AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite WHERE entite = @entite AND compte_entite = @compte)
    BEGIN
        SET @m = N'Le compte ' + ISNULL(@compte, N'vide') + N' n''est ni au plan OPCI ni au plan de l''entité.';
        THROW 50382, @m, 1;
    END;
    IF ISNULL(@debit, 0) < 0 OR ISNULL(@credit, 0) < 0 OR (ISNULL(@debit, 0) > 0 AND ISNULL(@credit, 0) > 0)
        THROW 50383, N'Une ligne porte un débit OU un crédit, positif.', 1;
    IF ISNULL(@debit, 0) = 0 AND ISNULL(@credit, 0) = 0
        THROW 50401, N'Ligne refusée : elle ne porte ni débit ni crédit. Une ligne d''OD porte un montant au débit ou au crédit.', 1;
    SELECT @qid = NULL, @cote_q = NULL, @fqid = NULL;
    IF @reference IS NOT NULL
    BEGIN
        SELECT @qid = q.id, @cote_q = fq.cote, @fqid = fq.id
        FROM dbo.ref_question q
        JOIN dbo.feuille_question fq ON fq.question_id = q.id
        JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.entite = @entite AND f.arrete = @arrete AND f.cote LIKE 'Q-%'
        WHERE q.reference = @reference;
        IF @qid IS NULL
        BEGIN
            SET @m = N'La question ' + @reference + N' n''est pas au programme de cet arrêté.';
            THROW 50384, @m, 1;
        END;
    END;
END;

GO

