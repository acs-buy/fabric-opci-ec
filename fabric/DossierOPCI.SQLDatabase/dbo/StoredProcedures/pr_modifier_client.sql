
CREATE   PROCEDURE dbo.pr_modifier_client
    @code               VARCHAR (20),
    @denomination       NVARCHAR (400) = NULL,
    @siren              CHAR (9)       = NULL,
    @forme_vehicule     VARCHAR (10)   = NULL,
    @forme_sociale      VARCHAR (10)   = NULL,
    @adresse_1          NVARCHAR (400) = NULL,
    @adresse_2          NVARCHAR (400) = NULL,
    @code_postal        VARCHAR (10)   = NULL,
    @ville              NVARCHAR (200) = NULL,
    @pays               CHAR (2)       = NULL,
    @dirigeant_nom      NVARCHAR (400) = NULL,
    @dirigeant_qualite  VARCHAR (60)   = NULL,
    @contact_nom        NVARCHAR (400) = NULL,
    @contact_courriel   NVARCHAR (400) = NULL,
    @contact_telephone  VARCHAR (30)   = NULL,
    @cloture            CHAR (5)       = NULL,
    @site_url           NVARCHAR (800) = NULL,
    @par                NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @code AND est_client = 1)
        THROW 50211, N'Ce code ne désigne pas un client du cabinet. Le code d''un client ne se modifie pas ; pour une filiale, passez par le périmètre.', 1;

    DECLARE @eff NVARCHAR (1) = N'-';
    DECLARE @fv VARCHAR (10), @fs VARCHAR (10), @si CHAR (9), @cl CHAR (5);
    SELECT @fv = COALESCE(NULLIF(LTRIM(RTRIM(@forme_vehicule)), ''), e.forme_vehicule),
           @fs = CASE WHEN @forme_sociale = @eff THEN NULL ELSE COALESCE(NULLIF(LTRIM(RTRIM(@forme_sociale)), ''), e.forme_sociale) END,
           @si = CASE WHEN @siren = @eff THEN NULL ELSE COALESCE(NULLIF(LTRIM(RTRIM(@siren)), ''), e.siren) END,
           @cl = COALESCE(NULLIF(LTRIM(RTRIM(@cloture)), ''), e.cloture)
      FROM dbo.ref_entite e WHERE e.code = @code;
    IF @fv NOT IN ('SPPICAV', 'FPI')
        THROW 50203, N'Un client est un véhicule : SPPICAV ou FPI.', 1;
    IF @fv = 'FPI' AND (@fs IS NOT NULL OR @si IS NOT NULL)
        THROW 50204, N'Un FPI n''a ni forme sociale ni SIREN : effacez-les avec « - » en même temps.', 1;
    IF TRY_CONVERT(DATE, @cl + '/2001', 103) IS NULL
        THROW 50205, N'La clôture s''écrit jour/mois, par exemple 31/12 ou 30/06.', 1;
    SET @site_url = NULLIF(LTRIM(RTRIM(@site_url)), N'');

    -- le site d'abord : son refus (lien mal forme) ne laisse rien d'ecrit
    IF @site_url IS NOT NULL
        EXEC dbo.pr_enregistrer_site_client @entite = @code, @site_url = @site_url, @par = @par;

    UPDATE e
       SET denomination      = COALESCE(NULLIF(LTRIM(RTRIM(@denomination)), N''), e.denomination),
           siren             = @si,
           forme_vehicule    = @fv,
           forme_sociale     = @fs,
           adresse_1         = COALESCE(NULLIF(LTRIM(RTRIM(@adresse_1)), N''), e.adresse_1),
           adresse_2         = CASE WHEN @adresse_2 = @eff THEN NULL ELSE COALESCE(NULLIF(LTRIM(RTRIM(@adresse_2)), N''), e.adresse_2) END,
           code_postal       = COALESCE(NULLIF(LTRIM(RTRIM(@code_postal)), ''), e.code_postal),
           ville             = COALESCE(NULLIF(LTRIM(RTRIM(@ville)), N''), e.ville),
           pays              = COALESCE(NULLIF(LTRIM(RTRIM(@pays)), ''), e.pays),
           dirigeant_nom     = COALESCE(NULLIF(LTRIM(RTRIM(@dirigeant_nom)), N''), e.dirigeant_nom),
           dirigeant_qualite = COALESCE(NULLIF(LTRIM(RTRIM(@dirigeant_qualite)), ''), e.dirigeant_qualite),
           contact_nom       = CASE WHEN @contact_nom = @eff THEN NULL ELSE COALESCE(NULLIF(LTRIM(RTRIM(@contact_nom)), N''), e.contact_nom) END,
           contact_courriel  = CASE WHEN @contact_courriel = @eff THEN NULL ELSE COALESCE(NULLIF(LTRIM(RTRIM(@contact_courriel)), N''), e.contact_courriel) END,
           contact_telephone = CASE WHEN @contact_telephone = @eff THEN NULL ELSE COALESCE(NULLIF(LTRIM(RTRIM(@contact_telephone)), ''), e.contact_telephone) END,
           cloture           = @cl,
           modifie_par       = @par,
           modifie_le        = SYSUTCDATETIME()
      FROM dbo.ref_entite e
     WHERE e.code = @code;

    SELECT @code AS code, N'Informations de ' + @code + N' mises à jour.' + CASE WHEN @site_url IS NULL THEN N'' ELSE N' Site SharePoint enregistré.' END
         + N' Le code du client ne change pas.' AS message;
END;

GO

