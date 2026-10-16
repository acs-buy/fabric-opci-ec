
-- les noms du lot B1, en lecture des vues basculees
CREATE   VIEW dbo.v_cellules_a_remplir_regle AS
SELECT entite, arrete, article, tableau, indicatif, cellules_a_remplir, cellules, imposees, en_attente, lecture FROM dbo.v_cellules_a_remplir;

GO

