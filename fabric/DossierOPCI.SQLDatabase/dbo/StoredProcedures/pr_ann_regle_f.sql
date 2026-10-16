
-- Regle F (oracle, regle_f) : frais d'acquisition cumules inscrits au 1041.
CREATE   PROCEDURE dbo.pr_ann_regle_f @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT,
                                         @comptes VARCHAR (400), @exclues VARCHAR (400), @regle VARCHAR (12) = 'RC7'
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '1041', '', N'*', 0);
    IF @s IS NULL
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @motif = N'arrêté sans balance', @regle = @regle;
        RETURN;
    END;
    IF @s = 0
    BEGIN
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'CALCULE', @valeur = 0, @source = N'compte 1041 nul : aucuns frais d’acquisition', @regle = @regle;
        RETURN;
    END;
    DECLARE @nrows INT, @sans INT, @nde INT, @sde DECIMAL (38, 12);
    SELECT @nrows = COUNT(*), @sans = SUM(CASE WHEN ISNULL(code_actif, '') = '' THEN 1 ELSE 0 END),
           @nde = SUM(CASE WHEN ISNULL(code_actif, '') <> '' AND dbo.fn_ann_poste_ok(@c, code_actif, @comptes, @exclues) = 1 THEN 1 ELSE 0 END),
           @sde = ISNULL(SUM(CASE WHEN ISNULL(code_actif, '') <> '' AND dbo.fn_ann_poste_ok(@c, code_actif, @comptes, @exclues) = 1 THEN solde END), 0)
    FROM dbo.annexe_w_axe WHERE calcul_id = @c AND arrete = @a AND compte_num LIKE '1041%';
    IF dbo.fn_ann_Sl(@c, @a, @comptes, @exclues) = 0 AND ISNULL(@nde, 0) = 0
    BEGIN
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'CALCULE', @valeur = 0, @source = N'ligne sans coût et sans frais d’acquisition ventilés sur ses actifs', @regle = @regle;
        RETURN;
    END;
    IF @nrows > 0 AND @sans = 0
    BEGIN
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'CALCULE', @valeur = @sde, @source = N'frais d’acquisition du 1041 ventilés par actif (comptabilité analytique)', @regle = @regle;
        RETURN;
    END;
    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @motif = N'écritures du 1041 non ventilées par actif', @regle = @regle;
END;

GO

