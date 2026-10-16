-- La cellule est etablie (oracle, Table.connue).
CREATE   FUNCTION dbo.fn_ann_connue (@calcul_id INT, @arrete VARCHAR (20), @article VARCHAR (10), @ligne NVARCHAR (120), @colonne TINYINT)
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.annexe_w_cel WHERE calcul_id = @calcul_id AND arrete = @arrete AND article = @article
                             AND ligne = @ligne AND colonne = @colonne AND etat IN ('LU', 'CALCULE', 'SAISI')) THEN 1 ELSE 0 END;
END;

GO

