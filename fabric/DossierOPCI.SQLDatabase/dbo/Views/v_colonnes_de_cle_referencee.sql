
-- --- 3 : O35, le recensement des colonnes de cle referencee -----------
-- LA REGLE PORTE SUR LA COLONNE, NON SUR LA TABLE. Une colonne qu'une
-- autre table reference ne peut pas etre saisie librement en grille : la
-- modifier romprait la reference. Elle passe en lecture seule, et le
-- geste qui la change devient un bouton. La vue rend la liste sur
-- laquelle le portail statuera, colonne par colonne.
CREATE   VIEW dbo.v_colonnes_de_cle_referencee AS
SELECT OBJECT_NAME(fkc.referenced_object_id)        AS table_referencee,
       COL_NAME(fkc.referenced_object_id,
                fkc.referenced_column_id)            AS colonne_referencee,
       COUNT(DISTINCT fk.parent_object_id)           AS tables_qui_referencent,
       STRING_AGG(OBJECT_NAME(fk.parent_object_id), ', ')
                                                     AS lesquelles,
       CAST(CASE WHEN EXISTS (
                SELECT 1 FROM sys.columns c
                WHERE c.object_id = fkc.referenced_object_id
                  AND c.name = 'message_ecran') THEN 1 ELSE 0 END AS BIT)
                                                     AS table_a_bouton,
       N'colonne a passer en lecture seule a l''ecran : une autre table la reference, et la modifier en grille romprait la reference'
                                                     AS lecture
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
GROUP BY fkc.referenced_object_id, fkc.referenced_column_id;

GO

