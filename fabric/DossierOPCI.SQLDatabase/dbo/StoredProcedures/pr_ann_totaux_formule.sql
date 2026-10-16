-- Les totaux sur la formule de calcul de ref_ligne_annexe (oracle, totaux_formule).
CREATE   PROCEDURE dbo.pr_ann_totaux_formule @c INT, @a VARCHAR (20), @art VARCHAR (10), @codes VARCHAR (400), @cols VARCHAR (40)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @code VARCHAR (24), @col TINYINT, @t NVARCHAR (MAX);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT LTRIM(RTRIM(x.value)), CAST(LTRIM(RTRIM(y.value)) AS TINYINT)
        FROM STRING_SPLIT(@codes, ',', 1) x CROSS JOIN STRING_SPLIT(@cols, ',', 1) y ORDER BY x.ordinal, y.ordinal;
    OPEN cur; FETCH NEXT FROM cur INTO @code, @col;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @t = dbo.fn_ann_termes_formule(@art, @code, @col);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @termes = @t;
        FETCH NEXT FROM cur INTO @code, @col;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

