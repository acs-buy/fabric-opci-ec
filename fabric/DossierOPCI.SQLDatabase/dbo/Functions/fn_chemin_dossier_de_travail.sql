CREATE FUNCTION dbo.fn_chemin_dossier_de_travail (@entite VARCHAR (20), @arrete VARCHAR (20), @fichier NVARCHAR (400))
RETURNS NVARCHAR (800)
AS
BEGIN
    -- le chemin d'un classeur du dossier de travail vu du coffre : /Coffre/, le raccourci du site du cabinet
    -- (ref_parametre RACCOURCI_SITE_CABINET, omis s'il manque), le dossier de l'arrete, puis le fichier ;
    -- egal a /Coffre/ suivi de export_dossier.chemin_onelake d'un depot hors sous-dossier quand le raccourci est
    -- declare, comme le chemin d'une piece par le raccourci du depot du client
    DECLARE @raccourci NVARCHAR (200) = (SELECT valeur FROM dbo.ref_parametre WHERE code = 'RACCOURCI_SITE_CABINET');
    RETURN N'/Coffre/' + ISNULL(NULLIF(@raccourci, N'') + N'/', N'') + dbo.fn_dossier_de_travail(@entite, @arrete, NULL)
         + N'/' + @fichier;
END

GO

