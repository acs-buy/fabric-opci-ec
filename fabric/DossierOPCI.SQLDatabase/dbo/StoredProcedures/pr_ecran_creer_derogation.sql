
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
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : avant fn_e3_refus_commun : l'arrete vide d'un vehicule choisi passe avant 50702 ; le vehicule vide garde 50701.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @vehicule COLLATE Latin1_General_100_BIN2)) > 0 AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    -- 327 fin
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

