
-- La ligne lue sur ses racines et son sens dans ref_ligne_annexe (oracle, lu_racines).
CREATE   PROCEDURE dbo.pr_ann_lu_racines @c INT, @a VARCHAR (20), @art VARCHAR (10), @code VARCHAR (24), @col TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @rac VARCHAR (300), @exc VARCHAR (300), @sens VARCHAR (8);
    SELECT @rac = racines, @exc = racines_exclues, @sens = sens FROM dbo.ref_ligne_annexe WHERE article = @art AND code = @code;
    DECLARE @s DECIMAL (38, 12) = dbo.fn_ann_Sl(@c, @a, REPLACE(ISNULL(@rac, ''), ' ', ''), REPLACE(ISNULL(@exc, ''), ' ', ''));
    DECLARE @v DECIMAL (38, 12) = CASE WHEN @s IS NULL THEN NULL WHEN @sens = 'DEBIT' THEN @s ELSE -@s END;
    DECLARE @src NVARCHAR (1000) = dbo.fn_ann_comptes_fr(@rac, @exc, @sens);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @v = @v, @source = @src, @motif = N'arrêté sans balance';
END;

GO

