CREATE   PROCEDURE dbo.pr_relever_inventaire_referentiel
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @tab VARCHAR (120), @sql NVARCHAR (1000);
    DECLARE @res TABLE (table_nom VARCHAR (120) PRIMARY KEY, lignes INT,
                        modifiees INT, derniere DATETIME2 (3));
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT r.table_nom FROM dbo.ref_referentiel r
        JOIN sys.tables t ON t.name = r.table_nom ORDER BY r.ordre;
    OPEN c;
    FETCH NEXT FROM c INTO @tab;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = N'SELECT ''' + @tab + N''', COUNT(*), '
                 + N'COUNT(modifie_le), MAX(modifie_le) FROM dbo.'
                 + QUOTENAME(@tab) + N';';
        INSERT INTO @res (table_nom, lignes, modifiees, derniere)
        EXEC sp_executesql @sql;
        FETCH NEXT FROM c INTO @tab;
    END;
    CLOSE c; DEALLOCATE c;

    MERGE dbo.inventaire_referentiel AS cible
    USING @res AS src ON cible.table_nom = src.table_nom
    WHEN MATCHED THEN UPDATE SET lignes = src.lignes,
        lignes_modifiees = src.modifiees,
        derniere_modification = src.derniere, releve_le = SYSUTCDATETIME()
    WHEN NOT MATCHED THEN INSERT
        (table_nom, lignes, lignes_modifiees, derniere_modification, releve_le)
        VALUES (src.table_nom, src.lignes, src.modifiees, src.derniere,
                SYSUTCDATETIME());
END;

GO

