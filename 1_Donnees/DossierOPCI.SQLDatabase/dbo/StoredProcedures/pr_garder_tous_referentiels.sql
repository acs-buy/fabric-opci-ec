
-- --- 3 : la garde se pose sur tout ce qui est inscrit ---------------
CREATE   PROCEDURE dbo.pr_garder_tous_referentiels
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @t VARCHAR (120);
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT r.table_nom
        FROM dbo.ref_referentiel r
        JOIN sys.tables t ON t.name = r.table_nom
        ORDER BY r.table_nom;
    OPEN c;
    FETCH NEXT FROM c INTO @t;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_garder_referentiel @t;
        FETCH NEXT FROM c INTO @t;
    END;
    CLOSE c;
    DEALLOCATE c;
END;

GO

