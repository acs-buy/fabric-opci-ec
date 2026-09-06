
-- --- 2 : la garde, dont le message derive du referentiel ------------
CREATE   PROCEDURE dbo.pr_garder_referentiel
    @table_nom VARCHAR (120)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = @table_nom)
        RETURN;

    DECLARE @qui_tient VARCHAR (20) =
        (SELECT TOP 1 qui_tient FROM dbo.ref_referentiel
         WHERE table_nom = @table_nom);

    DECLARE @role NVARCHAR (300) =
        CASE @qui_tient
             WHEN 'REVISEUR' THEN N'associé ou réviseur'
             WHEN 'BASE'     THEN N'associé. Cette table porte des valeurs livrées avec la base, recopiées depuis un texte : les modifier les fait diverger de leur source'
             ELSE N'associé' END;

    DECLARE @sql NVARCHAR (MAX) = N'CREATE OR ALTER TRIGGER dbo.'
        + QUOTENAME('tr_' + @table_nom + '_garde') + N'
ON dbo.' + QUOTENAME(@table_nom) + N'
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel(''' + @table_nom + N''',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N''Écriture refusée : la modification de ce référentiel du cabinet demande le rôle ' + @role + N'. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''''associé de porter la modification, ou de vous attribuer le rôle.'',
        1;
END;';
    EXEC sp_executesql @sql;
END;

GO

