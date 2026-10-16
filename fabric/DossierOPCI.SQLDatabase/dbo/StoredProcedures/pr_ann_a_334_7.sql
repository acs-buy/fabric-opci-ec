
-- ------------------------------------------------------------------------------------------------- 334-7
CREATE   PROCEDURE dbo.pr_ann_a_334_7 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '334-7', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @P VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @bas DATE = dbo.fn_ann_date(@c, @P), @haut DATE = dbo.fn_ann_date(@c, @a);
    DECLARE @pvs TABLE (code_actif VARCHAR (40), v DECIMAL (38, 12));
    IF @bas IS NOT NULL
        INSERT INTO @pvs SELECT code_actif, plus_ou_moins_value FROM dbo.v_plus_value_cession
        WHERE entite = @entite AND CAST(date_mouvement AS DATE) > @bas AND CAST(date_mouvement AS DATE) <= @haut;
    DECLARE @nat TABLE (n INT, code VARCHAR (24), comptes VARCHAR (200), exclues VARCHAR (200));
    INSERT INTO @nat VALUES (1, 'TERRAINS_NUS', '211', ''), (2, 'TERRAINS_CONSTR', '213', ''), (3, 'SOL_AUTRUI', '214', ''),
        (4, 'DROITS_REELS', '23', ''), (5, 'EN_COURS', '221,228', ''), (6, 'AUTRES', '21,22', '211,213,214,221,228'),
        (7, 'PARTS_2', '252', ''), (8, 'PARTS_3', '254', ''), (9, 'ACTIONS_4', '256', ''), (10, 'OPCI_5', '258', ''),
        (11, 'AUTRES_IMMO', '243,245,265,266', '');
    DECLARE @code VARCHAR (24), @cs VARCHAR (200), @ex VARCHAR (200), @k INT, @col TINYINT, @compte VARCHAR (4), @sg INT, @s DECIMAL (38, 12), @v DECIMAL (38, 12);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code, comptes, exclues FROM @nat ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code, @cs, @ex;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @k = 1;
        WHILE @k <= 2
        BEGIN
            SELECT @col = CASE @k WHEN 1 THEN 3 ELSE 4 END, @compte = CASE @k WHEN 1 THEN '761' ELSE '661' END, @sg = CASE @k WHEN 1 THEN 1 ELSE -1 END;
            SET @s = dbo.fn_ann_S(@c, @a, @compte, '', N'*', 0);
            IF @s IS NULL
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'arrêté sans balance', @regle = 'A334_7';
            ELSE IF @s = 0
            BEGIN
                DECLARE @s1 NVARCHAR (200) = N'compte ' + @compte + N' nul : aucune ' + CASE WHEN @sg > 0 THEN N'plus-value' ELSE N'moins-value' END + N' réalisée sur l’exercice';
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @etat = 'CALCULE', @valeur = 0, @source = @s1, @regle = 'A334_7';
            END;
            ELSE IF ISNULL((SELECT SUM(v) FROM @pvs WHERE @sg * v > 0), 0) = -@s
            BEGIN
                SET @v = ABS(ISNULL((SELECT SUM(v) FROM @pvs WHERE @sg * v > 0 AND dbo.fn_ann_poste_ok(@c, code_actif, @cs, @ex) = 1), 0));
                DECLARE @s2 NVARCHAR (300) = CASE WHEN @sg > 0 THEN N'plus-values' ELSE N'moins-values' END + N' des cessions de l’exercice, actif par actif, dont le total égale le compte ' + @compte;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @etat = 'CALCULE', @valeur = @v, @source = @s2, @regle = 'A334_7';
            END;
            ELSE
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'plus ou moins-values non rattachées aux actifs', @regle = 'A334_7';
            SET @k += 1;
        END;
        DECLARE @t NVARCHAR (200) = N'1|334-7|' + @code + N'|3;-1|334-7|' + @code + N'|4';
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @termes = @t, @regle = 'A334_7';
        IF dbo.fn_ann_etat(@c, @P, @art, @code, 1) IS NOT NULL
            EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        ELSE IF @P IS NOT NULL AND dbo.fn_ann_balance(@c, @P) = 1 AND dbo.fn_ann_S(@c, @P, '761', '', N'*', 0) = 0 AND dbo.fn_ann_S(@c, @P, '661', '', N'*', 0) = 0
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2, @etat = 'CALCULE', @valeur = 0, @source = N'761 et 661 nuls à l’arrêté N-1', @regle = 'A334_7';
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2, @motif = N'exercice N-1 absent de la base', @regle = 'A334_7';
        FETCH NEXT FROM cur INTO @code, @cs, @ex;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE @cols TABLE (n INT, col TINYINT);
    INSERT INTO @cols VALUES (1, 3), (2, 4), (3, 1), (4, 2);
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR SELECT col FROM @cols ORDER BY n;
    OPEN cur2; FETCH NEXT FROM cur2 INTO @col;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @ti NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|334-7|' + code + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @nat WHERE n <= 6);
        DECLARE @ta NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|334-7|' + code + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @nat WHERE n > 6);
        DECLARE @tg NVARCHAR (200) = N'1|334-7|TOTAL_IMMEUBLES|' + CAST(@col AS NVARCHAR (2)) + N';1|334-7|TOTAL_AUTRES|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL_IMMEUBLES', @col = @col, @termes = @ti, @regle = 'A334_7';
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL_AUTRES', @col = @col, @termes = @ta, @regle = 'A334_7';
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL_GENERAL', @col = @col, @termes = @tg, @regle = 'A334_7';
        FETCH NEXT FROM cur2 INTO @col;
    END;
    CLOSE cur2; DEALLOCATE cur2;
    DECLARE @pv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL_GENERAL', 3), @mv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL_GENERAL', 4);
    DECLARE @s761 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '761', '', N'*', 0), @s661 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '661', '', N'*', 0), @e DECIMAL (38, 12);
    IF @pv IS NOT NULL AND @s761 IS NOT NULL
    BEGIN
        SET @e = @pv + @s761;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_7_RESULTAT', @cle = N'plus-values', @ecart = @e;
    END;
    IF @mv IS NOT NULL AND @s661 IS NOT NULL
    BEGIN
        SET @e = @mv - @s661;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_7_RESULTAT', @cle = N'moins-values', @ecart = @e;
    END;
END;

GO

