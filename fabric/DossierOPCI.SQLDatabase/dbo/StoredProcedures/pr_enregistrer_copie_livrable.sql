

-- LA COPIE D'UN FICHIER VALIDE, tracee apres le visa.
CREATE   PROCEDURE dbo.pr_enregistrer_copie_livrable
    @document_id INT,
    @web_url     NVARCHAR (800),
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @m NVARCHAR (400);
    SELECT @entite = entite, @arrete = arrete FROM dbo.document_produit WHERE id = @document_id;
    IF @entite IS NULL
        THROW 50622, N'Copie refusée : l''arrêté n''est pas validé pour le client.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 0
        THROW 50622, N'Copie refusée : l''arrêté n''est pas validé pour le client.', 1;
    IF NULLIF(LTRIM(RTRIM(@web_url)), N'') IS NULL OR @web_url NOT LIKE N'https://%'
        THROW 50638, N'Copie refusée : l''adresse de la copie est une adresse https du site du véhicule.', 1;
    INSERT INTO dbo.copie_livrable (document_id, web_url, copie_par) VALUES (@document_id, @web_url, @par);
    SELECT SCOPE_IDENTITY() AS copie_id, N'Copie enregistrée.' AS message;
END;

GO

