
-- --- 3 : le releve compte selon le genre ----------------------------
CREATE   PROCEDURE dbo.pr_relever_controles
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_inscrire_controles;

    DECLARE @horodate DATETIME2 (3) = SYSUTCDATETIME();
    DECLARE @vue VARCHAR (120), @cond NVARCHAR (400), @genre VARCHAR (20);
    DECLARE @sql NVARCHAR (MAX), @lignes INT, @anomalies INT;

    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT c.vue, c.condition_anomalie, c.genre
        FROM dbo.ref_controle c
        JOIN sys.views v ON v.name = c.vue
        ORDER BY c.ordre;
    OPEN c;
    FETCH NEXT FROM c INTO @vue, @cond, @genre;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @lignes = 0; SET @anomalies = 0;
        BEGIN TRY
            -- Une MESURE compte ses lignes et n'en tire aucune anomalie.
            SET @sql = N'SELECT @l = COUNT(*), @a = SUM(CASE WHEN '
                     + CASE @genre
                            WHEN 'RAPPROCHEMENT' THEN N'(' + @cond + N')'
                            WHEN 'MESURE'        THEN N'1 = 0'
                            ELSE N'1 = 1' END
                     + N' THEN 1 ELSE 0 END) FROM dbo.' + QUOTENAME(@vue) + N';';
            EXEC sp_executesql @sql,
                 N'@l INT OUTPUT, @a INT OUTPUT',
                 @l = @lignes OUTPUT, @a = @anomalies OUTPUT;
            INSERT INTO dbo.releve_controle (releve_le, vue, lignes, anomalies)
            VALUES (@horodate, @vue, ISNULL(@lignes, 0), ISNULL(@anomalies, 0));
        END TRY
        BEGIN CATCH
            INSERT INTO dbo.releve_controle (releve_le, vue, lignes, anomalies,
                                             message)
            VALUES (@horodate, @vue, 0, 0,
                    N'le contrôle n''a pas pu être relevé : '
                    + LEFT(ERROR_MESSAGE(), 340));
        END CATCH;
        FETCH NEXT FROM c INTO @vue, @cond, @genre;
    END;
    CLOSE c;
    DEALLOCATE c;
END;

GO

