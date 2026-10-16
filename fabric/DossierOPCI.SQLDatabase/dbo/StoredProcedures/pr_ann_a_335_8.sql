
-- ------------------------------------------------------------------------------------------------- 335-8
CREATE   PROCEDURE dbo.pr_ann_a_335_8 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s_r3 NVARCHAR (MAX) = N'ligne ' + dbo.fn_ann_nom_etat('R_TIII') + N' du compte de résultat moins les autres produits du tableau',
            @residu NVARCHAR (MAX) = N'résidu de la ligne ' + dbo.fn_ann_nom_etat('R_TIV') + N' du compte de résultat';
    DECLARE @s_r4 NVARCHAR (MAX) = @residu + N' nul', @m_r4 NVARCHAR (MAX) = @residu + N' à répartir';
    DECLARE @art VARCHAR (10) = '335-8', @e DECIMAL (38, 12), @n INT, @s DECIMAL (38, 12), @r DECIMAL (38, 12), @code VARCHAR (24);
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'P', @col = 1, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'P', @col = 2, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'C', @col = 1, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'C', @col = 2, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_lignes_racines @c = @c, @a = @a, @art = @art, @codes = 'P_1,P_2,P_3,P_4,P_5,P_6,P_8,P_9,C_1,C_2,C_3,C_4';
    SET @e = dbo.fn_ann_E(@c, @a, 'R_TIII', 1);
    SELECT @n = COUNT(dbo.fn_ann_val(@c, @a, @art, value, 1)), @s = SUM(dbo.fn_ann_val(@c, @a, @art, value, 1)) FROM STRING_SPLIT('P_1,P_2,P_3,P_4,P_5,P_6,P_8,P_9', ',');
    IF @e IS NOT NULL AND @n = 8
    BEGIN
        SET @r = @e - @s;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'P_7', @col = 1, @etat = 'CALCULE', @valeur = @r, @source = @s_r3, @regle = 'RR';
    END;
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'P_7', @col = 1, @motif = N'résidu non calculable', @regle = 'RR';
    SET @e = dbo.fn_ann_E(@c, @a, 'R_TIV', 1);
    SELECT @n = COUNT(dbo.fn_ann_val(@c, @a, @art, value, 1)), @s = SUM(dbo.fn_ann_val(@c, @a, @art, value, 1)) FROM STRING_SPLIT('C_1,C_2,C_3,C_4', ',');
    SET @r = CASE WHEN @e IS NULL OR @n < 4 THEN NULL ELSE @e - @s END;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM (VALUES (1, 'C_5'), (2, 'C_6'), (3, 'C_7')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @r = 0
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = 'CALCULE', @valeur = 0, @source = @s_r4, @regle = 'RR';
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = @m_r4, @regle = 'RR';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur;
    IF @r IS NOT NULL AND @r <> 0
        EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = N'C_5;C_6;C_7', @col = 1, @parent = @r, @nom = @residu;
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'P_7';
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    EXEC dbo.pr_ann_totaux_formule @c = @c, @a = @a, @art = @art, @codes = 'P_ST,C_ST,TOTAL', @cols = '1,2';
    DECLARE @lib NVARCHAR (500) = N'Détail par nature des autres produits et autres charges financiers';
    IF dbo.fn_ann_connue(@c, @a, @art, N'P_9', 1) = 1 AND dbo.fn_ann_connue(@c, @a, @art, N'C_7', 1) = 1
       AND dbo.fn_ann_val(@c, @a, @art, N'P_9', 1) = 0 AND dbo.fn_ann_val(@c, @a, @art, N'C_7', 1) = 0
        EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = N'DETAIL_NATURE', @col = 1, @source = N'autres produits et autres charges financiers nuls',
             @obligation = 'CONDITIONNELLE', @regle = 'NEUVE', @libelle = @lib, @ordre = 22;
    ELSE
    BEGIN
        DECLARE @ob VARCHAR (14) = CASE WHEN (dbo.fn_ann_connue(@c, @a, @art, N'P_9', 1) = 1 AND dbo.fn_ann_val(@c, @a, @art, N'P_9', 1) <> 0)
                                          OR (dbo.fn_ann_connue(@c, @a, @art, N'C_7', 1) = 1 AND dbo.fn_ann_val(@c, @a, @art, N'C_7', 1) <> 0)
                                        THEN 'IMPOSEE' ELSE 'CONDITIONNELLE' END;
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'DETAIL_NATURE', @col = 1, @motif = N'détail par nature absent de la base', @nature = 'texte',
             @obligation = @ob, @fmt = 'texte', @regle = 'NEUVE', @libelle = @lib, @ordre = 22;
    END;
    DECLARE @col TINYINT = 1, @k INT, @l VARCHAR (24), @le VARCHAR (24);
    WHILE @col <= 2
    BEGIN
        SET @k = 1;
        WHILE @k <= 3
        BEGIN
            SELECT @l = CASE @k WHEN 1 THEN 'P_ST' WHEN 2 THEN 'C_ST' ELSE 'TOTAL' END, @le = CASE @k WHEN 1 THEN 'R_TIII' WHEN 2 THEN 'R_TIV' ELSE 'R_ROF' END;
            DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, @col), @ee DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, @le, @col);
            IF @v IS NOT NULL AND @ee IS NOT NULL
            BEGIN
                DECLARE @x DECIMAL (38, 12) = @v - @ee, @cle NVARCHAR (60) = @l + N' colonne ' + CAST(@col AS NVARCHAR (2));
                EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_8_RESULTAT', @cle = @cle, @ecart = @x;
            END;
            SET @k += 1;
        END;
        SET @col += 1;
    END;
END;

GO

