-- Les parts en circulation de l'entite a l'arrete (oracle, Dossier.parts), NULL sans ligne.
CREATE   FUNCTION dbo.fn_ann_parts (@c INT, @a VARCHAR (20))
RETURNS DECIMAL (38, 12)
AS
BEGIN
    RETURN (SELECT TOP (1) p.nombre_parts FROM dbo.parts_en_circulation p JOIN dbo.calcul_annexe ca ON ca.entite = p.entite
            WHERE ca.calcul_id = @c AND p.arrete = @a);
END;

GO

