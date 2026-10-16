
-- ------------------------------------------------------------------ n° 2 : conclure une limite
CREATE   PROCEDURE dbo.pr_ecran_conclure_ratio
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @code       NVARCHAR (120),
    @conclusion NVARCHAR (600),
    @par        NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_commun(@entite, @arrete, @par), @m NVARCHAR (1000);
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    SET @code = NULLIF(LTRIM(RTRIM(@code)), N'');
    IF @code IS NULL
        THROW 50800, N'Choisissez la limite dans la liste « Limite ».', 1;
    -- la limite se recoit par son code ou par son libelle (segment « Limite »)
    DECLARE @c VARCHAR (30), @libelle NVARCHAR (120), @forme VARCHAR (10), @pro VARCHAR (12);
    SELECT @c = code, @libelle = libelle, @forme = forme_vehicule, @pro = statut_professionnel
    FROM dbo.ref_ratio_memoire WHERE code = @code OR libelle = @code;
    IF @c IS NULL
    BEGIN
        SET @m = N'La limite « ' + REPLACE(@code, N'%', N'%%') + N' » n''est pas au référentiel des limites.';
        THROW 50801, @m, 1;
    END;
    SET @conclusion = NULLIF(LTRIM(RTRIM(@conclusion)), N'');
    IF @conclusion IS NULL
        THROW 50802, N'La conclusion est obligatoire : saisissez-la avant de conclure la limite.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50803, N'L''arrêté est validé pour le client : ses conclusions ne se reprennent plus.', 1;
    IF (@forme IS NOT NULL AND @forme <> ISNULL((SELECT forme_vehicule FROM dbo.ref_entite WHERE code = @entite), ''))
       OR (ISNULL((SELECT est_professionnel FROM dbo.ref_entite WHERE code = @entite), 0) = 1 AND @pro = 'SANS_OBJET')
    BEGIN
        SET @m = N'La limite « ' + REPLACE(@libelle, N'%', N'%%') + N' » est sans objet pour ce véhicule : elle ne se conclut pas.';
        THROW 50804, @m, 1;
    END;
    UPDATE dbo.conclusion_ratio SET conclusion = @conclusion, conclu_par = @par, conclu_le = SYSUTCDATETIME()
     WHERE entite = @entite AND arrete = @arrete AND code = @c;
    IF @@ROWCOUNT = 0
        INSERT INTO dbo.conclusion_ratio (entite, arrete, code, conclusion, conclu_par, conclu_le)
        VALUES (@entite, @arrete, @c, @conclusion, @par, SYSUTCDATETIME());
    SELECT @entite AS vehicule, N'Limite « ' + @libelle + N' » conclue au ' + dbo.fn_date_ecran(@arrete) + N'.' AS message;
END;

GO

