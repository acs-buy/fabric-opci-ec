-- L'annee d'un arrete (oracle, Dossier.annee).
CREATE   FUNCTION dbo.fn_ann_annee (@calcul_id INT, @arrete VARCHAR (20))
RETURNS INT
AS
BEGIN
    RETURN (SELECT annee FROM dbo.annexe_w_arr WHERE calcul_id = @calcul_id AND arrete = @arrete);
END;

GO

