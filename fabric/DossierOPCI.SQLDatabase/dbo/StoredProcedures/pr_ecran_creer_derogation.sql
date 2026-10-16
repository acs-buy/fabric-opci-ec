
-- pr_ecran_creer_derogation : 1 refus
-- ------------------------------------------------------------------ n° 7 : la derogation sur une feuille de valorisation
CREATE   PROCEDURE dbo.pr_ecran_creer_derogation
    @vehicule VARCHAR (20),
    @arrete   VARCHAR (20),
    @cote     VARCHAR (30),
    @motif    NVARCHAR (400),
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_commun(@vehicule, @arrete, @par), @m NVARCHAR (1000);
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    IF NULLIF(LTRIM(RTRIM(@cote)), '') IS NULL
        THROW 50760, N'Choisissez la feuille de valorisation dans la liste.', 1;
    DECLARE @entite VARCHAR (20) = (SELECT f.entite FROM dbo.feuille_travail f
                                    JOIN dbo.v_perimetre_vehicule p ON p.entite = f.entite AND p.arrete = f.arrete AND p.vehicule = @vehicule
                                    WHERE f.cote = @cote AND f.arrete = @arrete AND f.cycle IN ('VALO', 'PART'));
    IF @entite IS NULL
        THROW 50761, N'La feuille choisie n''est pas une feuille de valorisation ou des participations de ce véhicule à cet arrêté.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF @motif IS NULL
        THROW 50762, N'Le motif de la dérogation est obligatoire.', 1;
    DECLARE @deja INT = (SELECT TOP (1) id FROM dbo.derogation WHERE cote = @cote AND levee_le IS NULL ORDER BY id DESC);
    IF @deja IS NOT NULL
    BEGIN
        SET @m = N'Une dérogation est déjà en cours sur la feuille ' + @cote + N' (n° ' + CAST(@deja AS NVARCHAR (12)) + N').';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50764, @m, 1; END
    END;
    INSERT INTO dbo.derogation (entite, arrete, cote, motif, accordee_par, accordee_le)
    VALUES (@entite, @arrete, @cote, @motif, @par, SYSUTCDATETIME());
    DECLARE @id INT = CAST(SCOPE_IDENTITY() AS INT);
    SELECT @vehicule AS vehicule,
           N'Dérogation n° ' + CAST(@id AS NVARCHAR (12)) + N' créée sur la feuille ' + @cote + N' : elle attend le visa du chef de mission.' AS message,
           @id AS derogation_id;
END;

GO

