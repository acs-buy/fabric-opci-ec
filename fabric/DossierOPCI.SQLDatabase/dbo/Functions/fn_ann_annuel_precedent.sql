-- La cloture annuelle de ref_arrete qui precede l'arrete (oracle, Dossier.annuel_precedent).
CREATE   FUNCTION dbo.fn_ann_annuel_precedent (@c INT, @a VARCHAR (20))
RETURNS VARCHAR (20)
AS
BEGIN
    DECLARE @d DATE = (SELECT date_arrete FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    RETURN (SELECT TOP (1) arrete FROM dbo.annexe_w_arr WHERE calcul_id = @c AND type_arrete = 'ANNUEL' AND date_arrete < @d
            ORDER BY date_arrete DESC, arrete);
END;

GO

