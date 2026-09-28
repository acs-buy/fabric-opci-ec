
-- RESOUDRE UN FICHIER DEPOSE DANS « DEPOT DU CLIENT ». 28/09/2026.
-- Le reviseur depose le fichier dans la bibliotheque « Depot du client » du site du vehicule, puis
-- donne son nom, sous-dossier compris. La procedure rend les 3 chemins du meme fichier :
--   chemin_lecture  relatif a Files/, pour que la fonction le lise par le raccourci et en calcule l'empreinte ;
--   chemin_coffre   la meme chose vue du coffre, pour dbo.piece ;
--   web_url         le lien SharePoint, qui s'ouvre au clic.
-- LE SITE est celui du vehicule qui detient l'entite, sinon celui de l'entite, comme pour le depot.
-- LE RACCOURCI se nomme sp_<vehicule en minuscules, tirets en soulignes>_depot, convention de l'etape 12.
-- L'ADRESSE DE LA BIBLIOTHEQUE est « Dpt%20du%20client » : SharePoint retire les lettres accentuees de
-- l'adresse, releve sur Graph le 28/09/2026. La procedure ne verifie pas que le fichier existe : la
-- base ne voit pas SharePoint. La fonction le verifie en le lisant.
CREATE   PROCEDURE dbo.pr_resoudre_fichier_depot
    @entite   VARCHAR (20),
    @fichier  NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        THROW 50970, N'Entité inconnue.', 1;
    SET @fichier = LTRIM(RTRIM(REPLACE(@fichier, N'', N'/')));
    WHILE LEFT(@fichier, 1) = N'/' SET @fichier = SUBSTRING(@fichier, 2, 400);
    IF @fichier IS NULL OR LEN(@fichier) = 0
        THROW 50971, N'Donnez le nom du fichier tel que vous l''avez déposé dans « Dépôt du client », sous-dossier compris s''il y en a un.', 1;
    IF @fichier LIKE N'%..%' OR RIGHT(@fichier, 1) = N'/'
        THROW 50972, N'Le nom du fichier ne peut ni remonter d''un dossier, ni finir par une barre.', 1;
    DECLARE @vehicule VARCHAR (20), @site_url NVARCHAR (800);
    SELECT TOP 1 @vehicule = d.entite, @site_url = d.site_url FROM dbo.demande_espace_client d
    JOIN dbo.detention dt ON dt.entite_mere = d.entite
    WHERE dt.entite_fille = @entite AND d.statut = 'FAIT' AND d.site_url IS NOT NULL ORDER BY d.id DESC;
    IF @site_url IS NULL
        SELECT TOP 1 @vehicule = entite, @site_url = site_url FROM dbo.demande_espace_client
        WHERE entite = @entite AND statut = 'FAIT' AND site_url IS NOT NULL ORDER BY id DESC;
    IF @site_url IS NULL
        THROW 50973, N'Ni cette entité ni le véhicule qui la détient n''ont d''espace SharePoint : provisionnez d''abord celui du véhicule.', 1;
    DECLARE @raccourci NVARCHAR (200) = N'sp_' + LOWER(REPLACE(@vehicule, '-', '_')) + N'_depot';
    SELECT @raccourci + N'/' + @fichier AS chemin_lecture,
           N'/Coffre/' + @raccourci + N'/' + @fichier AS chemin_coffre,
           @site_url + N'/Dpt%20du%20client/' + dbo.fn_url_chemin(@fichier) AS web_url,
           RIGHT(@fichier, CHARINDEX(N'/', REVERSE(N'/' + @fichier)) - 1) AS nom_fichier,
           @vehicule AS vehicule;
END;

GO

