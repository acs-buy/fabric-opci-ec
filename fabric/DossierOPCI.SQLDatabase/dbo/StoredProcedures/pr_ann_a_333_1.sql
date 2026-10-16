
CREATE   PROCEDURE dbo.pr_ann_a_333_1 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n_cap NVARCHAR (MAX) = N'bilan, ligne ' + dbo.fn_ann_nom_etat('P_CP_1'),
            @n_rnar NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat('R_RNAR'),
            @n_pmvar NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat('R_PMVAR');
    DECLARE @art VARCHAR (10) = '333-1', @v DECIMAL (38, 12), @src NVARCHAR (200);
    SET @v = dbo.fn_ann_E(@c, @a, 'P_CP_1', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'CAPITAL', @col = 1, @v = @v,
         @source = @n_cap, @nature = 'etat', @regle = 'RC10';
    DECLARE @code VARCHAR (24), @rac VARCHAR (4), @col TINYINT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM (VALUES (1, 'SD'), (2, 'SD_RES'), (3, 'SD_AC'), (4, 'SD_REG_AC')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'rubrique', @regle = 'RC1';
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2, @motif = N'rubrique', @regle = 'RC1';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR
        SELECT code, rac FROM (VALUES (1, 'SD_REPORT_PMV', '112'), (2, 'SD_REG_PMV', '193'), (3, 'SD_REPORT_RES', '111'), (4, 'SD_REG_RES', '191')) x (n, code, rac) ORDER BY n;
    OPEN cur2; FETCH NEXT FROM cur2 INTO @code, @rac;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @v = -dbo.fn_ann_S(@c, @a, @rac, '', N'*', 0);
        SET @src = N'solde créditeur du ' + @rac;
        EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @v = @v, @source = @src, @motif = N'arrêté sans balance';
        FETCH NEXT FROM cur2 INTO @code, @rac;
    END;
    CLOSE cur2; DEALLOCATE cur2;
    SET @v = dbo.fn_ann_E(@c, @a, 'R_RNAR', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'SD_RES_NET', @col = 1, @v = @v, @source = @n_rnar, @nature = 'etat';
    SET @v = dbo.fn_ann_E(@c, @a, 'R_PMVAR', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'SD_RES_PMV', @col = 1, @v = @v, @source = @n_pmvar, @nature = 'etat';
    EXEC dbo.pr_ann_acomptes_333_1 @c = @c, @a = @a;
    -- colonne 2 : regle N, cellules d'etat pour CAPITAL, SD_RES_NET et SD_RES_PMV
    DECLARE @nat VARCHAR (8), @en1 VARCHAR (40);
    DECLARE cur3 CURSOR LOCAL FAST_FORWARD FOR
        SELECT code, nat, en1 FROM (VALUES (1, 'CAPITAL', 'etat', 'P_CP_1'), (2, 'SD_REPORT_PMV', 'source', NULL), (3, 'SD_REG_PMV', 'source', NULL),
            (4, 'SD_REPORT_RES', 'source', NULL), (5, 'SD_REG_RES', 'source', NULL), (6, 'SD_RES_NET', 'etat', 'R_RNAR'),
            (7, 'SD_RES_PMV', 'etat', 'R_PMVAR'), (8, 'SD_AC_NET', 'source', NULL), (9, 'SD_AC_PMV', 'source', NULL),
            (10, 'SD_REG_AC_NET', 'source', NULL), (11, 'SD_REG_AC_PMV', 'source', NULL)) x (n, code, nat, en1) ORDER BY n;
    OPEN cur3; FETCH NEXT FROM cur3 INTO @code, @nat, @en1;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code, @nature = @nat, @etat_n1 = @en1;
        FETCH NEXT FROM cur3 INTO @code, @nat, @en1;
    END;
    CLOSE cur3; DEALLOCATE cur3;
    DECLARE @dix NVARCHAR (MAX) = N'SD_REPORT_PMV;SD_REG_PMV;SD_REPORT_RES;SD_REG_RES;SD_RES_NET;SD_RES_PMV;SD_AC_NET;SD_AC_PMV;SD_REG_AC_NET;SD_REG_AC_PMV';
    DECLARE @t1 NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|333-1|' + value + N'|1', N';') WITHIN GROUP (ORDER BY ordinal) FROM STRING_SPLIT(@dix, N';', 1));
    DECLARE @t2 NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|333-1|' + value + N'|2', N';') WITHIN GROUP (ORDER BY ordinal) FROM STRING_SPLIT(@dix, N';', 1));
    -- SD_TOTAL : v_sommes_distribuables, a defaut la somme des 10 lignes
    DECLARE @t DECIMAL (38, 12) = dbo.fn_ann_num(@c, 'SD', @a);
    IF @t IS NOT NULL
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'SD_TOTAL', @col = 1, @etat = 'LU', @valeur = @t,
             @source = N'total des sommes distribuables de l’arrêté, tel que la base le calcule', @nature = 'calcul', @obligation = 'SANS', @regle = 'RL';
    ELSE
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'SD_TOTAL', @col = 1, @termes = @t1;
    EXEC dbo.pr_ann_n1_ou_somme @c = @c, @a = @a, @art = @art, @ligne = N'SD_TOTAL', @termes2 = @t2;
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @tc NVARCHAR (200) = N'1|333-1|CAPITAL|' + CAST(@col AS NVARCHAR (2)) + N';1|333-1|SD_TOTAL|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'CP_TOTAL', @col = @col, @termes = @tc;
        SET @col += 1;
    END;
    -- controles : CP_TOTAL = P_CP ; somme des 10 lignes = SD_TOTAL
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @cp DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'CP_TOTAL', @col), @pc DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'P_CP', @col);
        DECLARE @cle NVARCHAR (40) = N'colonne ' + CAST(@col AS NVARCHAR (2)), @e DECIMAL (38, 12);
        IF @cp IS NOT NULL AND @pc IS NOT NULL
        BEGIN
            SET @e = @cp - @pc;
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C333_1_CP', @cle = @cle, @ecart = @e;
        END;
        DECLARE @st DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'SD_TOTAL', @col);
        DECLARE @nconnues INT, @somme10 DECIMAL (38, 12);
        SELECT @nconnues = COUNT(dbo.fn_ann_val(@c, @a, @art, x.value, @col)), @somme10 = SUM(dbo.fn_ann_val(@c, @a, @art, x.value, @col))
        FROM STRING_SPLIT(@dix, N';') x;
        IF @st IS NOT NULL AND @nconnues = 10
        BEGIN
            SET @e = @somme10 - @st;
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C333_1_SD', @cle = @cle, @ecart = @e;
        END;
        SET @col += 1;
    END;
END;

GO

