
CREATE   VIEW dbo.v_a_viser AS
-- 06/09/2026, demande de Fabric IQ : objet_id, l'identifiant entier de l'objet quand la
-- reference en est un (LOT, DEROGATION, EVALUATION), NULL quand elle est textuelle
-- (CONCLUSION, PUBLICATION). Le panneau d'une automatisation PowerTable ne propose,
-- pour un parametre de type int, que les colonnes numeriques de la feuille. La colonne
-- est portee par chacune des 5 vues de detail, l'union reste plate.
SELECT * FROM dbo.v_a_viser_lot
UNION ALL SELECT * FROM dbo.v_a_viser_conclusion
UNION ALL SELECT * FROM dbo.v_a_viser_derogation
UNION ALL SELECT * FROM dbo.v_a_viser_evaluation
UNION ALL SELECT * FROM dbo.v_a_viser_publication;

GO

