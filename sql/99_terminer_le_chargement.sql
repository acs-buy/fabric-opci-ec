-- 99. À JOUER EN DERNIER, une fois tous les fichiers de données chargés.
--
-- POURQUOI CE FICHIER EXISTE
--     `00_preparer_le_chargement.sql` a suspendu les déclencheurs et la vérification des clés
--     étrangères. Tant qu'ils ne sont pas rétablis, votre base accepte des écritures que la
--     solution refuserait en exploitation : un dossier sans rôle, une référence vers une ligne
--     inexistante, une modification de référentiel sans le rôle d'associé.
--
-- CE QU'IL FAIT
--     1. Il rétablit la vérification des clés étrangères, EN CONTRÔLANT les données déjà chargées.
--        Si une référence est invalide, il vous le dit ici plutôt que de la laisser passer.
--     2. Il réactive les déclencheurs.
--     3. Il compte ce qui est en place, pour que vous compariez.

SET NOCOUNT ON;
PRINT 'Retablissement des cles etrangeres, avec controle des donnees chargees.';

DECLARE @sql NVARCHAR(MAX) = N'';
SELECT @sql = @sql + N'ALTER TABLE [' + s.name + N'].[' + t.name
     + N'] WITH CHECK CHECK CONSTRAINT ALL; '
  FROM sys.tables t
  JOIN sys.schemas s ON s.schema_id = t.schema_id
 WHERE t.is_ms_shipped = 0;
EXEC sp_executesql @sql;

PRINT 'Reactivation des declencheurs.';
SET @sql = N'';
SELECT @sql = @sql + N'ALTER TABLE [' + s.name + N'].[' + t.name + N'] ENABLE TRIGGER ALL; '
  FROM sys.tables t
  JOIN sys.schemas s ON s.schema_id = t.schema_id
 WHERE t.is_ms_shipped = 0
   AND EXISTS (SELECT 1 FROM sys.triggers g WHERE g.parent_id = t.object_id);
EXEC sp_executesql @sql;

-- Ce qui doit rester a zero.
SELECT 'declencheurs encore suspendus' AS quoi, COUNT(*) AS nb
  FROM sys.triggers WHERE is_disabled = 1 AND parent_class = 1;
SELECT 'cles etrangeres non verifiees' AS quoi, COUNT(*) AS nb
  FROM sys.foreign_keys WHERE is_not_trusted = 1;

-- Ce qui doit correspondre aux comptes annonces par le mode operatoire.
SELECT 'questions d''acceptation' AS quoi, COUNT(*) AS nb, 620 AS attendu FROM dbo.ref_question
UNION ALL SELECT 'comptes du plan',          COUNT(*), 200 FROM dbo.ref_compte
UNION ALL SELECT 'articles du reglement',    COUNT(*), 111 FROM dbo.ref_article
UNION ALL SELECT 'roles',                    COUNT(*),   4 FROM dbo.ref_role
UNION ALL SELECT 'natures de pieces',        COUNT(*),  10 FROM dbo.ref_nature_piece
UNION ALL SELECT 'entites de demonstration', COUNT(*),  16 FROM dbo.ref_entite;

PRINT 'Si les deux premiers comptes valent zero, la base est en ordre de marche.';
GO
