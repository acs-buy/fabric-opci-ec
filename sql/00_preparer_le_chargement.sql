-- 00. À JOUER EN PREMIER, avant tout fichier de données.
--
-- POURQUOI CE FICHIER EXISTE
--     La base porte 93 déclencheurs et 379 contraintes qui protègent les données en exploitation.
--     Deux d'entre eux empêchent le chargement initial, et le blocage est circulaire :
--
--     1. LES DÉCLENCHEURS DE GARDE refusent toute écriture dans un référentiel à qui ne détient pas
--        le rôle d'associé. Or, sur une base vide, personne ne détient de rôle : la table des rôles
--        est justement l'une de celles qu'il faut charger. Sans ce fichier, rien ne peut entrer.
--
--     2. LES CLÉS ÉTRANGÈRES s'appliquent ligne à ligne, y compris à l'intérieur d'une même table.
--        La table des normes se référence elle-même, une norme pouvant en abroger une autre : la
--        première ligne insérée désigne alors une ligne qui n'existe pas encore.
--
--     Mesuré le 26/09/2026 sur une installation réelle : sans ce fichier, 55 des 78 fichiers de
--     données échouent.
--
-- CE QU'IL FAIT
--     Il suspend les déclencheurs et la vérification des clés étrangères, le temps du chargement.
--     Il ne supprime rien et ne modifie aucune donnée.
--
-- CE QU'IL NE DISPENSE PAS DE FAIRE
--     Jouer `99_terminer_le_chargement.sql` à la fin. Tant qu'il ne l'est pas, votre base accepte
--     des écritures que la solution refuserait en exploitation.

SET NOCOUNT ON;
PRINT 'Suspension des declencheurs et des cles etrangeres, le temps du chargement.';

DECLARE @sql NVARCHAR(MAX) = N'';

-- Les declencheurs de toutes les tables de l'utilisateur.
SELECT @sql = @sql + N'ALTER TABLE [' + s.name + N'].[' + t.name + N'] DISABLE TRIGGER ALL; '
  FROM sys.tables t
  JOIN sys.schemas s ON s.schema_id = t.schema_id
 WHERE t.is_ms_shipped = 0
   AND EXISTS (SELECT 1 FROM sys.triggers g WHERE g.parent_id = t.object_id);
EXEC sp_executesql @sql;

SET @sql = N'';
-- La verification des cles etrangeres et des contraintes de controle.
SELECT @sql = @sql + N'ALTER TABLE [' + s.name + N'].[' + t.name + N'] NOCHECK CONSTRAINT ALL; '
  FROM sys.tables t
  JOIN sys.schemas s ON s.schema_id = t.schema_id
 WHERE t.is_ms_shipped = 0;
EXEC sp_executesql @sql;

SELECT 'declencheurs suspendus' AS quoi, COUNT(*) AS nb
  FROM sys.triggers WHERE is_disabled = 1 AND parent_class = 1;
SELECT 'contraintes suspendues' AS quoi, COUNT(*) AS nb
  FROM sys.foreign_keys WHERE is_disabled = 1;

PRINT 'Vous pouvez maintenant jouer les fichiers de 10_referentiels puis de 80_demonstration.';
PRINT 'N OUBLIEZ PAS 99_terminer_le_chargement.sql a la fin.';
GO
