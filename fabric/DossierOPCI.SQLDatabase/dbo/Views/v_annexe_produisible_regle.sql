CREATE   VIEW dbo.v_annexe_produisible_regle AS
SELECT entite, arrete, cellules_a_remplir, bloquantes, tableaux, produisible, articles_fautifs, lecture, en_attente, cases_vides, obstacles,
       message_obstacle FROM dbo.v_annexe_produisible;

GO

