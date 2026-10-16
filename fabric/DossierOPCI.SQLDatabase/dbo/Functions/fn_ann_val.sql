-- La valeur d'une cellule etablie (LU, CALCULE, SAISI) ; NULL sinon : oracle, Table.val.
CREATE   FUNCTION dbo.fn_ann_val (@calcul_id INT, @arrete VARCHAR (20), @article VARCHAR (10), @ligne NVARCHAR (120), @colonne TINYINT)
RETURNS DECIMAL (38, 12)
AS
BEGIN
    RETURN (SELECT valeur FROM dbo.annexe_w_cel WHERE calcul_id = @calcul_id AND arrete = @arrete AND article = @article
            AND ligne = @ligne AND colonne = @colonne AND etat IN ('LU', 'CALCULE', 'SAISI'));
END;

GO

