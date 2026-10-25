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

    -- Objet n° 16 de l'ecran 5 (script 317, 19/10/2026) : une table qui porte pose_par, ref_parametre, a son
    -- propre horodatage, sur pose_par et pose_le (objet n° 19) ; la protection n'y pose ni modifie_par, ni
    -- modifie_le, ni tr_<table>_horodatage, et ne reecrit pas le sien.
    IF COL_LENGTH('dbo.' + @table_nom, 'pose_par') IS NOT NULL
        RETURN;

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

    -- Objet n° 16 de l'ecran 5 (script 317, 20/10/2026) : l'auteur s'ecrit a la longueur de modifie_par,
    -- nvarchar(400) quand cette procedure cree la colonne, nvarchar(200) sur ref_aide et ref_colonne_libelle ;
    -- le CAST coupe une identite plus longue que la colonne, que la mise a jour refuserait sinon (troncature).
    DECLARE @lg NVARCHAR (10) =
        (SELECT CASE WHEN c.max_length = -1 THEN N'MAX'
                     WHEN TYPE_NAME(c.system_type_id) IN ('nchar', 'nvarchar') THEN CAST(c.max_length / 2 AS NVARCHAR (10))
                     ELSE CAST(c.max_length AS NVARCHAR (10)) END
         FROM sys.columns c
         WHERE c.object_id = OBJECT_ID('dbo.' + @table_nom) AND c.name = 'modifie_par');

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
    -- Objet n° 16 de l''ecran 5 (script 317) : l''auteur est celui que la procedure d''ecran pose dans le
    -- contexte par, a defaut le compte connecte, a la longueur de la colonne modifie_par.
    UPDATE t SET modifie_par = CAST(COALESCE(SESSION_CONTEXT(N''par''), SUSER_SNAME()) AS NVARCHAR (' + @lg + N')), modifie_le = SYSUTCDATETIME()
    FROM dbo.' + QUOTENAME(@table_nom) + N' t
    JOIN inserted i ON ' + @cle + N';
END;';
    EXEC sp_executesql @sql;
END;

GO

