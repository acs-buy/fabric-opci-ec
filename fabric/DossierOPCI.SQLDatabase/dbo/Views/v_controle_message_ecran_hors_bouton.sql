
-- C90 : une colonne de message posee sur une table qui ne porte aucun
-- bouton. La regle est « jamais sur les 93 tables » : la liste des tables
-- a bouton est fermee, et toute autre porteuse est une derive.
CREATE   VIEW dbo.v_controle_message_ecran_hors_bouton AS
SELECT OBJECT_NAME(c.object_id) AS table_nom,
       N'cette table porte une colonne message_ecran sans porter de bouton : la colonne n''a rien a y faire'
                                           AS lecture
FROM sys.columns c
WHERE c.name = 'message_ecran'
  AND OBJECT_NAME(c.object_id) NOT IN ('lot_ecritures', 'feuille_travail', 'derogation', 'evaluation_actif', 'synthese_proposee', 'acceptation_mission', 'maintien_mission', 'ref_arrete', 'obligation_distribution', 'decision_distribution');

GO

