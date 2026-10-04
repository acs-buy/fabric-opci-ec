
-- PLANIFIER LES ARRETES DES FILIALES D'UN VEHICULE A LA DATE D'UN DE SES ARRETES.
CREATE   PROCEDURE dbo.pr_planifier_arretes_filiales
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @date DATE, @type VARCHAR (14);
    SELECT @date = date_arrete, @type = type_arrete FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete;
    IF @date IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND forme_vehicule IS NOT NULL) RETURN;
    DECLARE @f VARCHAR (20), @cl VARCHAR (10), @fin DATE, @m NVARCHAR (400), @n INT = 0;
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT ep.entite_fille, e.cloture FROM dbo.eligibilite_participation ep JOIN dbo.ref_entite e ON e.code = ep.entite_fille
        WHERE ep.entite_mere = @entite AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete x WHERE x.entite = ep.entite_fille AND x.arrete = @arrete);
    OPEN c; FETCH NEXT FROM c INTO @f, @cl;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @fin = dbo.fn_cloture_contenant(@cl, @date);
        IF @fin IS NULL
        BEGIN
            SET @m = N'Planification refusée : la date de clôture de la filiale ' + @f + N', « ' + ISNULL(@cl, N'') + N' », ne se lit pas comme un jour et un mois ; son exercice ne se détermine pas.';
            THROW 50601, @m, 1;
        END;
        INSERT INTO dbo.ref_arrete (entite, arrete, date_arrete, exercice, date_cloture, type_arrete, nature_technique,
                                    trimestre, rang_exercice, est_arrete_client, porte_balance)
        VALUES (@f, @arrete, @date, CONVERT(VARCHAR (10), @fin, 23), @fin, CASE WHEN @date = @fin THEN 'ANNUEL' ELSE @type END, 'HORS_MISSION',
                DATEPART(QUARTER, @date),
                1 + ISNULL((SELECT COUNT(DISTINCT exercice) FROM dbo.ref_arrete WHERE entite = @f AND exercice < CONVERT(VARCHAR (10), @fin, 23)), 0),
                0, 0);
        SET @n += 1;
        FETCH NEXT FROM c INTO @f, @cl;
    END;
    CLOSE c; DEALLOCATE c;
END;

GO

