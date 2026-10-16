
-- ------------------------------------------------------------------------------------------------- 335-2
CREATE   PROCEDURE dbo.pr_ann_a_335_2 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-2', @v DECIMAL (38, 12), @s DECIMAL (38, 12), @src NVARCHAR (200), @col TINYINT, @e DECIMAL (38, 12), @cle NVARCHAR (60);
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'CL', @col = 1, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'CL', @col = 2, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'AC', @col = 1, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'AC', @col = 2, @motif = N'rubrique', @regle = 'RC1';
    EXEC dbo.pr_ann_lignes_racines @c = @c, @a = @a, @art = @art, @codes = 'CL_1,CL_2,CL_3,AC_1,AC_2,AC_3,AC_4,AC_5,AC_6';
    EXEC dbo.pr_ann_totaux_formule @c = @c, @a = @a, @art = @art, @codes = 'CL_ST,AC_ST,TOTAL', @cols = '1,2';
    DECLARE @k INT = 1, @code VARCHAR (24), @dot VARCHAR (4), @rep VARCHAR (4);
    WHILE @k <= 2
    BEGIN
        SELECT @code = CASE @k WHEN 1 THEN 'DEP_CL' ELSE 'DEP_AC' END, @dot = CASE @k WHEN 1 THEN '681' ELSE '682' END,
               @rep = CASE @k WHEN 1 THEN '781' ELSE '782' END;
        EXEC dbo.pr_ann_lu_racines @c = @c, @a = @a, @art = @art, @code = @code;
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        SET @s = dbo.fn_ann_S(@c, @a, @dot, '', N'*', 0); SET @src = N'solde débiteur du ' + @dot;
        EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 3, @v = @s, @source = @src, @motif = N'arrêté sans balance', @regle = 'RC7';
        SET @s = -dbo.fn_ann_S(@c, @a, @rep, '', N'*', 0); SET @src = N'solde créditeur du ' + @rep;
        EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 4, @v = @s, @source = @src, @motif = N'arrêté sans balance', @regle = 'RC7';
        SET @k += 1;
    END;
    EXEC dbo.pr_ann_totaux_formule @c = @c, @a = @a, @art = @art, @codes = 'DEP_TOTAL', @cols = '1,2,3,4';
    SET @k = 1;
    WHILE @k <= 2
    BEGIN
        SET @code = CASE @k WHEN 1 THEN 'DEP_CL' ELSE 'DEP_AC' END;
        DECLARE @x2 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, 2), @x3 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, 3),
                @x4 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, 4), @x1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @code, 1);
        IF @x1 IS NOT NULL AND @x2 IS NOT NULL AND @x3 IS NOT NULL AND @x4 IS NOT NULL
        BEGIN
            SET @e = @x2 + @x3 - @x4 - @x1; SET @cle = @code;
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_2_DEPRECIATIONS', @cle = @cle, @ecart = @e;
        END;
        SET @k += 1;
    END;
    SET @k = 1;
    WHILE @k <= 2
    BEGIN
        DECLARE @l VARCHAR (24) = CASE @k WHEN 1 THEN 'CL_ST' ELSE 'AC_ST' END, @b VARCHAR (24) = CASE @k WHEN 1 THEN 'A_AUTRE_1' ELSE 'A_AUTRE_2' END;
        SET @col = 1;
        WHILE @col <= 2
        BEGIN
            DECLARE @vv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, @col), @ee DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, @b, @col);
            IF @vv IS NOT NULL AND @ee IS NOT NULL
            BEGIN
                SET @e = @vv - @ee; SET @cle = @l + N' colonne ' + CAST(@col AS NVARCHAR (2));
                EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_2_BILAN', @cle = @cle, @ecart = @e;
            END;
            SET @col += 1;
        END;
        SET @k += 1;
    END;
END;

GO

