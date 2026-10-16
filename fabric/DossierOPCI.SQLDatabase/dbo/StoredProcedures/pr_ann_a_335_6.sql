
-- ------------------------------------------------------------------------------------------------- 335-6
CREATE   PROCEDURE dbo.pr_ann_a_335_6 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-6', @col TINYINT = 1;
    EXEC dbo.pr_ann_lignes_racines @c = @c, @a = @a, @art = @art, @codes = 'D_1,D_2,D_3,D_4,D_5';
    EXEC dbo.pr_ann_totaux_formule @c = @c, @a = @a, @art = @art, @codes = 'TOTAL', @cols = '1,2';
    WHILE @col <= 2
    BEGIN
        DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', @col), @e DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'P_DET_5', @col);
        IF @v IS NOT NULL AND @e IS NOT NULL
        BEGIN
            DECLARE @x DECIMAL (38, 12) = @v - @e, @cle NVARCHAR (40) = N'colonne ' + CAST(@col AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_6_BILAN', @cle = @cle, @ecart = @x;
        END;
        SET @col += 1;
    END;
END;

GO

