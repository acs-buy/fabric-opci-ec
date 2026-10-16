-- L'etat d'une cellule par son texte.
CREATE   FUNCTION dbo.fn_ann_texte_etat (@etat VARCHAR (12))
RETURNS NVARCHAR (40)
AS
BEGIN
    RETURN CASE @etat WHEN 'LU' THEN N'cellule lue' WHEN 'CALCULE' THEN N'cellule calculée' WHEN 'SAISI' THEN N'cellule saisie'
                      WHEN 'A_REMPLIR' THEN N'cellule à remplir' WHEN 'EN_ATTENTE' THEN N'calcul en attente' WHEN 'SANS_OBJET' THEN N'cellule sans objet' END;
END;

GO

