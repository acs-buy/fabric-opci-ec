
-- --- 3 : la cle du curseur, une ligne par montant ----------------------
-- Le modele semantique exige une cle sur une seule colonne du cote 1
-- d'une relation. Le montant seul n'est pas unique entre arretes.
CREATE   VIEW dbo.v_montant_simulable_cle AS
SELECT m.cle_arrete + '|' + CONVERT(VARCHAR (24), m.montant_simulable)
           AS cle_montant,
       m.cle_arrete, m.entite, m.arrete, m.exercice, m.montant_simulable
FROM dbo.v_montant_simulable m;

GO

