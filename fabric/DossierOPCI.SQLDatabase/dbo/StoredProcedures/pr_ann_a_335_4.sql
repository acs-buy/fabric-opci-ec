
-- ------------------------------------------------------------------------------------------------- 335-4
CREATE   PROCEDURE dbo.pr_ann_a_335_4 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-4', @k INT = 1, @code VARCHAR (24), @lb VARCHAR (24), @immo VARCHAR (24), @nimmo VARCHAR (24), @v DECIMAL (38, 12),
            @src NVARCHAR (400), @m NVARCHAR (400);
    WHILE @k <= 2
    BEGIN
        SELECT @code = CASE @k WHEN 1 THEN 'EC' ELSE 'AUTRES' END, @lb = CASE @k WHEN 1 THEN 'P_DET_1' ELSE 'P_DET_2' END,
               @immo = CASE @k WHEN 1 THEN 'EC_IMMO' ELSE 'AUTRES_IMMO' END, @nimmo = CASE @k WHEN 1 THEN 'EC_NON_IMMO' ELSE 'AUTRES_NON_IMMO' END;
        SET @v = dbo.fn_ann_E(@c, @a, @lb, 1); SET @src = N'bilan passif, ligne ' + dbo.fn_ann_nom_etat(@lb);
        EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @v = @v, @source = @src, @nature = 'etat', @regle = 'RC10';
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code, @nature = 'etat', @etat_n1 = @lb;
        DECLARE @pv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, 1);
        DECLARE @rac TABLE (n INT, r VARCHAR (40));
        DELETE @rac;
        INSERT INTO @rac SELECT x.ordinal, LTRIM(RTRIM(x.value)) FROM dbo.ref_ligne_etat le CROSS APPLY STRING_SPLIT(ISNULL(le.racines, ''), ',', 1) x
        WHERE le.code = @lb AND LTRIM(RTRIM(x.value)) <> '';
        DECLARE @r512 VARCHAR (400) = ISNULL((SELECT STRING_AGG(r, ',') WITHIN GROUP (ORDER BY n) FROM @rac WHERE r LIKE '512%'), ''),
                @r513 VARCHAR (400) = ISNULL((SELECT STRING_AGG(r, ',') WITHIN GROUP (ORDER BY n) FROM @rac WHERE r LIKE '513%'), ''),
                @autres VARCHAR (400) = ISNULL((SELECT STRING_AGG(r, ',') WITHIN GROUP (ORDER BY n) FROM @rac WHERE r NOT LIKE '512%' AND r NOT LIKE '513%'), '');
        DECLARE @hors DECIMAL (38, 12) = CASE WHEN @autres <> '' THEN dbo.fn_ann_Sl(@c, @a, @autres, '') WHEN dbo.fn_ann_balance(@c, @a) = 1 THEN 0 END;
        DECLARE @cs VARCHAR (100) = @immo + ',' + @nimmo, @cs2 NVARCHAR (100) = @immo + N';' + @nimmo;
        DECLARE @nom_c NVARCHAR (MAX) = dbo.fn_ann_nom_ligne(@c, @a, @art, @code);
        IF @pv = 0
            EXEC dbo.pr_ann_composantes @c = @c, @a = @a, @art = @art, @parent = @code, @parent_col = 1, @codes = @cs, @col = 1;
        ELSE IF @pv IS NOT NULL AND @hors = 0
        BEGIN
            SET @v = CASE WHEN @r512 <> '' THEN -dbo.fn_ann_Sl(@c, @a, @r512, '') ELSE 0 END;
            SET @src = CASE WHEN @r512 <> '' THEN N'solde créditeur du 512, emprunts liés à des actifs immobiliers (plan, p. 111), compte de la ligne ' + dbo.fn_ann_nom_etat(@lb) + N' du bilan passif'
                            ELSE N'la ligne ' + dbo.fn_ann_nom_etat(@lb) + N' du bilan passif ne regroupe pas le compte 512' END;
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @immo, @col = 1, @etat = 'LU', @valeur = @v, @regle = 'A335_4', @source = @src;
            SET @v = CASE WHEN @r513 <> '' THEN -dbo.fn_ann_Sl(@c, @a, @r513, '') ELSE 0 END;
            SET @src = CASE WHEN @r513 <> '' THEN N'solde créditeur du 513, autres emprunts (plan, p. 111), compte de la ligne ' + dbo.fn_ann_nom_etat(@lb) + N' du bilan passif'
                            ELSE N'la ligne ' + dbo.fn_ann_nom_etat(@lb) + N' du bilan passif ne regroupe pas le compte 513' END;
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @nimmo, @col = 1, @etat = 'LU', @valeur = @v, @regle = 'A335_4', @source = @src;
            EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = @cs2, @col = 1, @parent = @pv, @nom = @nom_c;
        END;
        ELSE
        BEGIN
            SET @m = CASE WHEN @hors IS NULL THEN N'arrêté sans balance'
                          ELSE N'comptes ' + dbo.fn_ann_liste_fr(@autres) + N' de la ligne ' + dbo.fn_ann_nom_etat(@lb) + N' du bilan passif non ventilés par le plan (' + dbo.fn_ann_format('montant', -@hors) + N')' END;
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @immo, @col = 1, @motif = @m, @regle = 'A335_4';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @nimmo, @col = 1, @motif = @m, @regle = 'A335_4';
            EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = @cs2, @col = 1, @parent = @pv, @nom = @nom_c;
        END;
        EXEC dbo.pr_ann_composantes_n1 @c = @c, @a = @a, @art = @art, @parent = @code, @codes = @cs;
        SET @k += 1;
    END;
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = 1, @termes = N'1|335-4|EC|1;1|335-4|AUTRES|1';
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = 2, @termes = N'1|335-4|EC|2;1|335-4|AUTRES|2';
    DECLARE @t DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', 1);
    SET @k = 1;
    WHILE @k <= 2
    BEGIN
        SET @code = CASE @k WHEN 1 THEN 'TAUX_FIXE' ELSE 'RATIOS' END;
        IF @t = 0
            EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @source = N'aucun emprunt à la clôture', @obligation = 'CONDITIONNELLE';
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'caractéristiques des emprunts, absentes de la base',
                 @fmt = 'texte', @nature = 'texte', @obligation = 'CONDITIONNELLE', @regle = 'TXT';
        SET @k += 1;
    END;
    DECLARE @col TINYINT = 1;
    WHILE @col <= 2
    BEGIN
        SET @k = 1;
        WHILE @k <= 2
        BEGIN
            SELECT @code = CASE @k WHEN 1 THEN 'EC' ELSE 'AUTRES' END, @immo = CASE @k WHEN 1 THEN 'EC_IMMO' ELSE 'AUTRES_IMMO' END,
                   @nimmo = CASE @k WHEN 1 THEN 'EC_NON_IMMO' ELSE 'AUTRES_NON_IMMO' END;
            DECLARE @p DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, @col), @y1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @immo, @col),
                    @y2 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @nimmo, @col);
            IF @p IS NOT NULL AND @y1 IS NOT NULL AND @y2 IS NOT NULL
            BEGIN
                DECLARE @e DECIMAL (38, 12) = @p - (@y1 + @y2), @cle NVARCHAR (60) = @code + N' colonne ' + CAST(@col AS NVARCHAR (2));
                EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_4_COMPOSANTES', @cle = @cle, @ecart = @e;
            END;
            SET @k += 1;
        END;
        SET @col += 1;
    END;
END;

GO

