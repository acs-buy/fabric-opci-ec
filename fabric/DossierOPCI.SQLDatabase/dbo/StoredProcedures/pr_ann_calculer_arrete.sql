
-- Les articles, dans l'ordre de l'oracle (Table.calculer). Un article dont la procedure n'existe pas encore est
-- ignore : B1 se pose article par article, chacun prouve a l'oracle.
CREATE   PROCEDURE dbo.pr_ann_calculer_arrete @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @p SYSNAME, @sql NVARCHAR (400);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT p FROM (VALUES (1, 'pr_ann_a_311_1'), (2, 'pr_ann_a_331_1'), (3, 'pr_ann_a_332_1'), (4, 'pr_ann_a_332_2'),
            (5, 'pr_ann_a_333_1'), (6, 'pr_ann_a_333_2'), (7, 'pr_ann_a_333_3'), (8, 'pr_ann_a_334_1'), (9, 'pr_ann_a_334_2'),
            (10, 'pr_ann_a_334_3'), (11, 'pr_ann_a_334_5'), (12, 'pr_ann_a_334_6'), (13, 'pr_ann_a_334_7'),
            (14, 'pr_ann_a_334_8'), (15, 'pr_ann_a_335_1'), (16, 'pr_ann_a_335_2'), (17, 'pr_ann_a_335_3'),
            (18, 'pr_ann_a_335_4'), (19, 'pr_ann_a_335_5'), (20, 'pr_ann_a_335_6'), (21, 'pr_ann_a_335_7'),
            (22, 'pr_ann_a_335_8'), (23, 'pr_ann_a_335_9'), (24, 'pr_ann_a_335_10'), (25, 'pr_ann_a_335_11'),
            (26, 'pr_ann_a_335_12'), (27, 'pr_ann_a_336_1'), (28, 'pr_ann_a_336_2'), (29, 'pr_ann_a_336_3'),
            (30, 'pr_ann_a_332_1_distributions')) x (n, p)
        WHERE OBJECT_ID('dbo.' + p) IS NOT NULL ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @p;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = N'EXEC dbo.' + QUOTENAME(@p) + N' @c = @c, @a = @a;';
        EXEC sp_executesql @sql, N'@c INT, @a VARCHAR (20)', @c = @c, @a = @a;
        FETCH NEXT FROM cur INTO @p;
    END;
    CLOSE cur; DEALLOCATE cur;
    EXEC dbo.pr_ann_finir @c = @c, @a = @a;
END;

GO

