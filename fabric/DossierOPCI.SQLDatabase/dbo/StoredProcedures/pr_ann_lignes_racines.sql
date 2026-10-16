-- Pour chaque ligne : lue sur ses racines, puis la regle N (oracle, lignes_racines).
CREATE   PROCEDURE dbo.pr_ann_lignes_racines @c INT, @a VARCHAR (20), @art VARCHAR (10), @codes VARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @code VARCHAR (24);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@codes, ',', 1) ORDER BY ordinal;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_lu_racines @c = @c, @a = @a, @art = @art, @code = @code;
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

