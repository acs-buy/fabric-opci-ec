-- L'etat d'une cellule, NULL si elle n'existe pas.
CREATE   FUNCTION dbo.fn_ann_etat (@calcul_id INT, @arrete VARCHAR (20), @article VARCHAR (10), @ligne NVARCHAR (120), @colonne TINYINT)
RETURNS VARCHAR (12)
AS
BEGIN
    RETURN (SELECT etat FROM dbo.annexe_w_cel WHERE calcul_id = @calcul_id AND arrete = @arrete AND article = @article
            AND ligne = @ligne AND colonne = @colonne);
END;

GO

