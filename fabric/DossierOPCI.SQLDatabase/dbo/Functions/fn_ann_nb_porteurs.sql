CREATE   FUNCTION dbo.fn_ann_nb_porteurs (@c INT)
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM dbo.porteur p JOIN dbo.calcul_annexe ca ON ca.entite = p.entite WHERE ca.calcul_id = @c);
END;

GO

