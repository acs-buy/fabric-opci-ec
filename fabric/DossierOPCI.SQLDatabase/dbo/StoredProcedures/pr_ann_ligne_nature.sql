
-- 334-2 et 334-5 (oracle, tableau_natures) : une ligne de nature. @groupes : les groupes de la regle D ou la ligne a un
-- membre, « compte_de_difference#membres#indice » separes par « ~ ». Colonnes : N, N-1, augmentations, diminutions,
-- variation, frais.
CREATE   PROCEDURE dbo.pr_ann_ligne_nature
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @code VARCHAR (24), @comptes VARCHAR (400), @exclues VARCHAR (400),
    @groupes VARCHAR (4000), @col_n TINYINT, @col_n1 TINYINT, @col_aug TINYINT, @col_dim TINYINT, @col_var TINYINT, @col_frais TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @P VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @g TABLE (n INT, d VARCHAR (10), membres VARCHAR (2000), i INT);
    INSERT INTO @g SELECT x.ordinal, PARSENAME(REPLACE(x.value, '#', '.'), 3), REPLACE(PARSENAME(REPLACE(REPLACE(x.value, '.', CHAR(2)), '#', '.'), 2), CHAR(2), '.'),
                          CAST(PARSENAME(REPLACE(x.value, '#', '.'), 1) AS INT)
    FROM STRING_SPLIT(@groupes, '~', 1) x WHERE x.value <> '';
    -- DE(N) et DE(N-1) de la ligne, sommes de ses membres ; NULL des qu'un membre ne s'attribue pas
    DECLARE @dn DECIMAL (38, 12) = 0, @rn VARCHAR (200) = '', @dp DECIMAL (38, 12) = 0, @nul_n BIT = 0, @nul_p BIT = 0, @rn_echec VARCHAR (20),
            @tn NVARCHAR (MAX) = N'', @tn_echec NVARCHAR (400);
    DECLARE @gd VARCHAR (10), @gm VARCHAR (2000), @gi INT, @v DECIMAL (38, 12), @r VARCHAR (20);
    DECLARE @cn DECIMAL (38, 12) = dbo.fn_ann_Sl(@c, @a, @comptes, @exclues);
    IF @cn IS NULL SELECT @nul_n = 1, @rn_echec = 'sans balance', @tn_echec = N'arrêté sans balance';
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT d, membres, i FROM @g ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @gd, @gm, @gi;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @nul_n = 0
        BEGIN
            SELECT @v = v, @r = regle FROM dbo.fn_ann_de(@c, @a, @gd, @gm, @gi);
            IF @v IS NULL SELECT @nul_n = 1, @rn_echec = @r, @tn_echec = dbo.fn_ann_phrase_d(@r, @gd);
            ELSE SELECT @dn += @v, @rn += CASE WHEN @rn = '' THEN '' ELSE '/' END + @r,
                        @tn += CASE WHEN @tn = N'' THEN N'' ELSE N' ; ' END + dbo.fn_ann_phrase_d(@r, @gd);
        END;
        IF @nul_p = 0
        BEGIN
            IF @P IS NULL OR dbo.fn_ann_Sl(@c, @P, @comptes, @exclues) IS NULL SET @nul_p = 1;
            ELSE
            BEGIN
                SELECT @v = v, @r = regle FROM dbo.fn_ann_de(@c, @P, @gd, @gm, @gi);
                IF @v IS NULL SET @nul_p = 1; ELSE SET @dp += @v;
            END;
        END;
        FETCH NEXT FROM cur INTO @gd, @gm, @gi;
    END;
    CLOSE cur; DEALLOCATE cur;
    IF @P IS NULL OR dbo.fn_ann_Sl(@c, @P, @comptes, @exclues) IS NULL SET @nul_p = 1;
    IF @rn = '' SET @rn = 'D0';
    IF @tn = N'' SET @tn = N'coût nul, aucune différence d’estimation';
    IF @nul_n = 1
    BEGIN
        DECLARE @m NVARCHAR (400) = N'différence d’estimation non attribuable : ' + @tn_echec;
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col_n, @motif = @m, @regle = 'RC7';
    END;
    ELSE
    BEGIN
        DECLARE @et VARCHAR (12) = CASE WHEN @rn LIKE '%D3%' THEN 'CALCULE' ELSE 'LU' END, @val DECIMAL (38, 12) = @cn + @dn,
                @src NVARCHAR (MAX) = N'coût, plus la différence d’estimation : ' + @tn;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col_n, @etat = @et, @valeur = @val, @regle = 'RC7', @source = @src;
    END;
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col_n1, @de_art = @art, @de_ligne = @code, @de_col = @col_n;
    EXEC dbo.pr_ann_regle_m @c = @c, @a = @a, @art = @art, @ligne = @code, @col_aug = @col_aug, @col_dim = @col_dim, @comptes = @comptes, @exclues = @exclues;
    IF @nul_n = 0 AND @nul_p = 0
    BEGIN
        DECLARE @var DECIMAL (38, 12) = @dn - @dp;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col_var, @etat = 'CALCULE', @valeur = @var, @source = N'différence d’estimation à la clôture N moins celle à la clôture N-1, chacune établie sur la balance de sa clôture', @regle = 'RC7';
    END;
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col_var, @motif = N'différence d’estimation non attribuable à l’une des 2 clôtures', @regle = 'RC7';
    EXEC dbo.pr_ann_regle_f @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col_frais, @comptes = @comptes, @exclues = @exclues;
    DECLARE @v1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, @col_n1), @v2 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, @col_aug),
            @v3 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, @col_dim), @v4 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, @col_var),
            @v5 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, @col_n);
    IF @v1 IS NOT NULL AND @v2 IS NOT NULL AND @v3 IS NOT NULL AND @v4 IS NOT NULL AND @v5 IS NOT NULL
    BEGIN
        DECLARE @e DECIMAL (38, 12) = @v1 + @v2 - @v3 + @v4 - @v5, @cle NVARCHAR (120) = @art + N' ' + @code;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_BOUCLAGE', @cle = @cle, @ecart = @e;
    END;
END;

GO

