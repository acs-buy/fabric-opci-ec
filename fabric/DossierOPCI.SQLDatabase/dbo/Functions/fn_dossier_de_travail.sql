CREATE FUNCTION dbo.fn_dossier_de_travail (@entite VARCHAR (20), @arrete VARCHAR (20), @sous_dossier NVARCHAR (100))
RETURNS NVARCHAR (400)
AS
BEGIN
    -- le dossier d'un arrete au site du cabinet : Dossiers de travail/<entite>/<arrete>, suivi du sous-dossier
    -- quand il est donne ; pr_deposer_classeur y depose les classeurs des feuilles de travail
    RETURN N'Dossiers de travail/' + @entite + N'/' + @arrete + ISNULL(N'/' + @sous_dossier, N'');
END

GO

