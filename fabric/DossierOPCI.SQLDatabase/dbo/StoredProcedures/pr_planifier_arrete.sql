

-- --- 1. planifier un arrete au referentiel ------------------------------------------------------
CREATE   PROCEDURE dbo.pr_planifier_arrete
    @entite        VARCHAR (20),
    @date_arrete   DATE,
    @date_cloture  DATE,            -- la cloture annuelle de l'exercice auquel l'arrete se rattache
    @type_arrete   VARCHAR (14),    -- ANNUEL, SEMESTRIEL, INTERMEDIAIRE
    @par           NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
        THROW 50221, N'Un arrêté se planifie sur un client du cabinet. L''entité désignée n''en est pas un.', 1;
    IF @type_arrete NOT IN ('ANNUEL', 'SEMESTRIEL', 'INTERMEDIAIRE')
        THROW 50222, N'Le type d''un arrêté est ANNUEL, SEMESTRIEL ou INTERMEDIAIRE.', 1;
    IF @date_arrete > @date_cloture
        THROW 50223, N'La date de l''arrêté ne dépasse pas la clôture de son exercice.', 1;
    IF @type_arrete = 'ANNUEL' AND @date_arrete <> @date_cloture
        THROW 50224, N'Un arrêté annuel se date de la clôture de l''exercice.', 1;

    DECLARE @arrete VARCHAR (20) = CONVERT(VARCHAR (10), @date_arrete, 23);
    DECLARE @exercice VARCHAR (20) = CONVERT(VARCHAR (10), @date_cloture, 23);
    IF EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        -- les arretes des filiales suivent, meme pour un arrete deja planifie
        EXEC dbo.pr_planifier_arretes_filiales @entite, @arrete, @par;
        SELECT @arrete AS arrete, N'L''arrêté ' + @arrete + N' était déjà au référentiel.' AS message;
        RETURN;
    END;

    -- rang_exercice : le rang de l'exercice dans la mission, 1 pour le premier.
    DECLARE @rang SMALLINT = 1 + ISNULL((SELECT COUNT(DISTINCT exercice) FROM dbo.ref_arrete
                                         WHERE entite = @entite AND nature_technique = 'MISSION'
                                           AND exercice < @exercice), 0);
    INSERT INTO dbo.ref_arrete
        (entite, arrete, date_arrete, exercice, date_cloture, type_arrete, nature_technique,
         trimestre, rang_exercice, est_arrete_client, porte_balance)
    VALUES
        (@entite, @arrete, @date_arrete, @exercice, @date_cloture, @type_arrete, 'MISSION',
         DATEPART(QUARTER, @date_arrete), @rang, 1, 0);
    -- un arrete de chaque filiale, a la meme date
    EXEC dbo.pr_planifier_arretes_filiales @entite, @arrete, @par;

    SELECT @arrete AS arrete, N'Arrêté ' + @arrete + N' planifié, exercice ' + @exercice + N'.' AS message;
END;

GO

