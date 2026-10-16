
-- ------------------------------------------------------------------------------------------------- 335-3
CREATE   PROCEDURE dbo.pr_ann_a_335_3 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-3', @s DECIMAL (38, 12), @col TINYINT;
    EXEC dbo.pr_ann_lu_racines @c = @c, @a = @a, @art = @art, @code = 'PROVISIONS';
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'PROVISIONS';
    SET @s = dbo.fn_ann_S(@c, @a, '683', '', N'*', 0);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'PROVISIONS', @col = 3, @v = @s, @source = N'solde débiteur du 683', @motif = N'arrêté sans balance', @regle = 'RC7';
    SET @s = -dbo.fn_ann_S(@c, @a, '783', '', N'*', 0);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'PROVISIONS', @col = 4, @v = @s, @source = N'solde créditeur du 783', @motif = N'arrêté sans balance', @regle = 'RC7';
    SET @col = 1;
    WHILE @col <= 4
    BEGIN
        DECLARE @t NVARCHAR (100) = N'1|335-3|PROVISIONS|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @termes = @t;
        SET @col += 1;
    END;
    DECLARE @x2 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'PROVISIONS', 2), @x3 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'PROVISIONS', 3),
            @x4 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'PROVISIONS', 4), @x1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'PROVISIONS', 1);
    IF @x1 IS NOT NULL AND @x2 IS NOT NULL AND @x3 IS NOT NULL AND @x4 IS NOT NULL
    BEGIN
        DECLARE @e DECIMAL (38, 12) = @x2 + @x3 - @x4 - @x1;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_3_PROVISIONS', @cle = N'PROVISIONS', @ecart = @e;
    END;
END;

GO

