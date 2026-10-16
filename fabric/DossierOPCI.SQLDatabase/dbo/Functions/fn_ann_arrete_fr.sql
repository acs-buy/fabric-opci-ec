
-- Revision 12.3 (specification, 3.6, point 12) : un arrete par sa date, jj/mm/aaaa (ref_arrete.date_arrete), et non par
-- sa cle ; « inconnu » sans arrete (oracle, Dossier.arrete_fr).
CREATE   FUNCTION dbo.fn_ann_arrete_fr (@c INT, @a VARCHAR (20))
RETURNS NVARCHAR (40)
AS
BEGIN
    IF NULLIF(@a, '') IS NULL RETURN N'inconnu';
    DECLARE @d DATE = (SELECT date_arrete FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    RETURN CASE WHEN @d IS NOT NULL THEN CONVERT(NVARCHAR (10), @d, 103) ELSE dbo.fn_ann_date_fr(@a) END;
END;

GO

