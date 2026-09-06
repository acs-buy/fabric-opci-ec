
-- La vue que l'ecran R0 lit, posee sur la table d'inventaire.
CREATE   VIEW dbo.v_inventaire_referentiel AS
SELECT r.ordre, r.libelle, r.ecran_lu, r.qui_tient,
       COALESCE(i.lignes, 0)            AS lignes,
       COALESCE(i.lignes_modifiees, 0)  AS lignes_modifiees,
       i.derniere_modification,
       CASE WHEN i.table_nom IS NULL          THEN N'non relevé'
            WHEN i.lignes = 0                 THEN N'vide'
            WHEN i.lignes_modifiees = 0       THEN N'importé'
            WHEN i.lignes_modifiees = i.lignes THEN N'tenu au portail'
            ELSE N'importé, ' + CAST(i.lignes_modifiees AS NVARCHAR (10))
                 + N' ligne(s) modifiée(s) au portail' END AS etat,
       i.releve_le,
       r.table_nom
FROM dbo.ref_referentiel r
LEFT JOIN dbo.inventaire_referentiel i ON i.table_nom = r.table_nom;

GO

