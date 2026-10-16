
-- ------------------------------------------------------------------------------------------------- 335-12
CREATE   PROCEDURE dbo.pr_ann_a_335_12 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n_rnar NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat('R_RNAR'),
            @n_pmvar NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat('R_PMVAR');
    DECLARE @art VARCHAR (10) = '335-12', @v DECIMAL (38, 12), @col TINYINT, @t NVARCHAR (MAX), @code VARCHAR (24);
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT code FROM (VALUES (1, 'I'), (2, 'I_D'), (3, 'I_A'), (4, 'II'), (5, 'II_D'), (6, 'II_A')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'rubrique', @regle = 'RC1';
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2, @motif = N'rubrique', @regle = 'RC1';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    -- revision 12 : « Le cas échéant, il est à détailler pour chaque catégorie de parts » (p. 105) ; aucune table ne
    -- porte de categorie de parts
    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'DETAIL_CATEGORIES', @col = 1,
         @motif = N'catégories de parts absentes de la base : le détail par catégorie, demandé le cas échéant, se saisit',
         @fmt = 'texte', @nature = 'texte', @obligation = 'CONDITIONNELLE', @regle = 'NEUVE', @libelle = N'Détail par catégorie de parts', @ordre = 0;
    SET @v = dbo.fn_ann_E(@c, @a, 'R_RNAR', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'I_D_1', @col = 1, @v = @v, @source = @n_rnar, @nature = 'etat';
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'I_D_1', @nature = 'etat', @etat_n1 = 'R_RNAR';
    SET @v = dbo.fn_ann_E(@c, @a, 'R_PMVAR', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'II_D_1', @col = 1, @v = @v, @source = @n_pmvar, @nature = 'etat';
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'II_D_1', @nature = 'etat', @etat_n1 = 'R_PMVAR';
    EXEC dbo.pr_ann_lu_racines @c = @c, @a = @a, @art = @art, @code = 'I_D_2';
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'I_D_2';
    EXEC dbo.pr_ann_lu_racines @c = @c, @a = @a, @art = @art, @code = 'II_D_2';
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'II_D_2';
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        SET @t = N'-1|333-1|SD_AC_NET|' + CAST(@col AS NVARCHAR (2)) + N';-1|333-1|SD_REG_AC_NET|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'I_D_3', @col = @col, @termes = @t, @regle = 'H3';
        SET @t = N'-1|333-1|SD_AC_PMV|' + CAST(@col AS NVARCHAR (2)) + N';-1|333-1|SD_REG_AC_PMV|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'II_D_3', @col = @col, @termes = @t, @regle = 'H3';
        SET @t = dbo.fn_ann_termes_formule(@art, 'I_D_T', @col);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'I_D_T', @col = @col, @termes = @t;
        SET @t = dbo.fn_ann_termes_formule(@art, 'II_D_T', @col);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'II_D_T', @col = @col, @termes = @t;
        SET @col += 1;
    END;
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        EXEC dbo.pr_ann_affectation @c = @c, @a = @a, @section = 'I', @col = @col;
        SET @t = N'1|335-12|I_A_1|' + CAST(@col AS NVARCHAR (2)) + N';1|335-12|I_A_2|' + CAST(@col AS NVARCHAR (2)) + N';1|335-12|I_A_3|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'I_A_T', @col = @col, @termes = @t;
        EXEC dbo.pr_ann_affectation @c = @c, @a = @a, @section = 'II', @col = @col;
        SET @t = N'1|335-12|II_A_1|' + CAST(@col AS NVARCHAR (2)) + N';1|335-12|II_A_2|' + CAST(@col AS NVARCHAR (2)) + N';1|335-12|II_A_3|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'II_A_T', @col = @col, @termes = @t;
        SET @col += 1;
    END;
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @k INT = 1;
        WHILE @k <= 2
        BEGIN
            DECLARE @d VARCHAR (24) = CASE @k WHEN 1 THEN 'I_D_T' ELSE 'II_D_T' END, @af VARCHAR (24) = CASE @k WHEN 1 THEN 'I_A_T' ELSE 'II_A_T' END;
            DECLARE @v1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @d, @col), @v2 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @af, @col);
            IF @v1 IS NOT NULL AND @v2 IS NOT NULL
            BEGIN
                DECLARE @e DECIMAL (38, 12) = @v2 - @v1, @cle NVARCHAR (60) = @af + N' colonne ' + CAST(@col AS NVARCHAR (2));
                EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_12_AFFECTATION', @cle = @cle, @ecart = @e;
            END;
            SET @k += 1;
        END;
        SET @col += 1;
    END;
    DECLARE @a1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'I_A_1', 2), @dpv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, '333-3', N'DISTRIB_PREC', 1),
            @iiv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'II_D_T', 2);
    IF @a1 IS NOT NULL AND @dpv IS NOT NULL AND @iiv = 0
    BEGIN
        DECLARE @ed DECIMAL (38, 12) = @a1 - @dpv;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_12_DISTRIB_PREC', @cle = N'I_A_1 colonne 2', @ecart = @ed;
    END;
    EXEC dbo.pr_ann_acomptes @c = @c, @a = @a, @prefixe = 'ACPT_N', @k = 1, @x = @a;
    EXEC dbo.pr_ann_acomptes @c = @c, @a = @a, @prefixe = 'ACPT_N1', @k = 2, @x = @n1;
END;

GO

