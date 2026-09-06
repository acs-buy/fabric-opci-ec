

-- --- 2 : la protection d'un referentiel ------------------------------
-- Elle pose les 2 colonnes et le declencheur d'horodatage sur la table
-- nommee, si elle existe et si elle porte une cle primaire. Chaque semis
-- l'appelle sur sa table, juste apres pr_debut_semis : la colonne existe
-- ainsi au moment ou le semis la lit, quel que soit le rang du script
-- qui a cree la table.
--
-- LA JOINTURE DU DECLENCHEUR SE LIT DE LA CLE PRIMAIRE, non d'une
-- colonne devinee : une jointure sur une colonne supposee horodaterait
-- les mauvaises lignes.
CREATE   PROCEDURE dbo.pr_proteger_referentiel
    @table_nom VARCHAR (120)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @table_nom)
        RETURN;                       -- la table n'existe pas encore

    DECLARE @sql NVARCHAR (MAX);

    IF NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID('dbo.' + @table_nom)
                     AND name = 'modifie_par')
    BEGIN
        SET @sql = N'ALTER TABLE dbo.' + QUOTENAME(@table_nom)
                 + N' ADD modifie_par NVARCHAR (400) NULL;';
        EXEC sp_executesql @sql;
    END;

    IF NOT EXISTS (SELECT 1 FROM sys.columns
                   WHERE object_id = OBJECT_ID('dbo.' + @table_nom)
                     AND name = 'modifie_le')
    BEGIN
        SET @sql = N'ALTER TABLE dbo.' + QUOTENAME(@table_nom)
                 + N' ADD modifie_le DATETIME2 (3) NULL;';
        EXEC sp_executesql @sql;
    END;

    -- Le declencheur, refait a chaque appel : CREATE OR ALTER le rend
    -- idempotent, et la cle primaire peut avoir change entre 2 versions.
    DECLARE @cle NVARCHAR (MAX) =
        (SELECT STRING_AGG(CAST(N't.' + QUOTENAME(c.name) + N' = i.'
                                + QUOTENAME(c.name) AS NVARCHAR (MAX)),
                           N' AND ') WITHIN GROUP (ORDER BY ic.key_ordinal)
         FROM sys.tables t
         JOIN sys.key_constraints k ON k.parent_object_id = t.object_id
                                   AND k.type = 'PK'
         JOIN sys.index_columns ic ON ic.object_id = t.object_id
                                  AND ic.index_id = k.unique_index_id
         JOIN sys.columns c ON c.object_id = t.object_id
                           AND c.column_id = ic.column_id
         WHERE t.name = @table_nom);

    IF @cle IS NULL
        RETURN;    -- sans cle primaire, la jointure serait devinee

    SET @sql = N'CREATE OR ALTER TRIGGER dbo.'
        + QUOTENAME('tr_' + @table_nom + '_horodatage') + N'
ON dbo.' + QUOTENAME(@table_nom) + N'
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Un semis ne marque pas la ligne comme modifiee : sans quoi son
    -- premier passage interdirait a tous les suivants de corriger leurs
    -- propres lignes.
    IF CAST(ISNULL(SESSION_CONTEXT(N''semis''), 0) AS INT) = 1 RETURN;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    UPDATE t SET modifie_par = SUSER_SNAME(), modifie_le = SYSUTCDATETIME()
    FROM dbo.' + QUOTENAME(@table_nom) + N' t
    JOIN inserted i ON ' + @cle + N';
END;';
    EXEC sp_executesql @sql;
END;

GO

