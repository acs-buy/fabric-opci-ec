-- L'arrete ANNUEL dont l'exercice tombe en l'annee @y, au plus tard a @au_plus_tard (oracle, Dossier.annuel_de) : le
-- 1er dans l'ordre des codes.
CREATE   FUNCTION dbo.fn_ann_annuel_de (@calcul_id INT, @y INT, @au_plus_tard DATE)
RETURNS VARCHAR (20)
AS
BEGIN
    RETURN (SELECT TOP (1) arrete FROM dbo.annexe_w_arr
            WHERE calcul_id = @calcul_id AND type_arrete = 'ANNUEL' AND annee = @y AND (@au_plus_tard IS NULL OR date_arrete <= @au_plus_tard)
            ORDER BY arrete COLLATE Latin1_General_100_BIN2);
END;

GO

