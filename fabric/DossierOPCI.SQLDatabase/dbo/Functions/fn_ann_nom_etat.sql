-- Une ligne du bilan ou du compte de resultat, par son libelle de ref_ligne_etat entre guillemets.
CREATE   FUNCTION dbo.fn_ann_nom_etat (@code VARCHAR (40))
RETURNS NVARCHAR (820)
AS
BEGIN
    RETURN dbo.fn_ann_guillemets((SELECT libelle FROM dbo.ref_ligne_etat WHERE code = @code));
END;

GO

