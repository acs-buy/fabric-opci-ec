
CREATE VIEW dbo.v_a_viser AS
-- objet_id : l'identifiant entier de l'objet quand la reference en est un (LOT, DEROGATION,
-- EVALUATION), NULL quand elle est textuelle (CONCLUSION, PUBLICATION). La colonne est portee
-- par chacune des 5 vues de detail, l'union reste plate.
SELECT * FROM dbo.v_a_viser_lot
UNION ALL SELECT * FROM dbo.v_a_viser_conclusion
UNION ALL SELECT * FROM dbo.v_a_viser_derogation
UNION ALL SELECT * FROM dbo.v_a_viser_evaluation
UNION ALL SELECT * FROM dbo.v_a_viser_publication;

GO

