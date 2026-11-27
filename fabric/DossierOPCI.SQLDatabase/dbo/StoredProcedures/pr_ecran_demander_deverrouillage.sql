-- --- pr_ecran_demander_deverrouillage ----------------------------------------------------------
-- Bouton « Déverrouiller le dossier » de l'ecran 2, etape 6 (fonction demander_deverrouillage de
-- fn_ecran_revision) ; le demandeur est la connexion, jamais tape. Le dossier verrouille est celui de l'entite meme
-- (dossier_verrou), comme pr_deverrouiller_dossier. Le vide de @entite et @arrete : les 29 caracteres de
-- str.isspace() ; celui du motif est juge par dbo.fn_texte_vide, qui ote les memes caracteres puis tient aussi
-- pour vide un reste que la collation de la base egale a la chaine vide ; un motif rempli n'est rogne que des espaces
-- (LTRIM, RTRIM).
CREATE PROCEDURE dbo.pr_ecran_demander_deverrouillage @entite VARCHAR (20), @arrete VARCHAR (20), @motif NVARCHAR (800), @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE);
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51240, N'Demande refusée : aucun dossier de travail verrouillé pour le véhicule et l''arrêté des sélecteurs.', 1;
    IF dbo.fn_membre_equipe(@entite, @arrete, @par, @le) = 0
        THROW 51241, N'Demande refusée : votre adresse de connexion n''est rattachée à aucun membre de l''équipe de ce dossier.', 1;
    IF dbo.fn_peut_viser_nature(@entite, @par, 'REVUE', @le) = 1
        THROW 51242, N'Demande refusée : vous décidez les déverrouillages de ce dossier ; la demande vient d''un autre membre de l''équipe.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 51243, N'Demande refusée : l''arrêté est validé pour le client ; son dossier se rouvre par « Demander la réouverture ».', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete AND verrouille = 1)
        THROW 51240, N'Demande refusée : aucun dossier de travail verrouillé pour le véhicule et l''arrêté des sélecteurs.', 1;
    IF EXISTS (SELECT 1 FROM dbo.demande_reouverture WHERE entite = @entite AND arrete = @arrete AND etat = 'EN_ATTENTE')
        THROW 51244, N'Demande refusée : une demande attend déjà la décision du chef de mission pour cet arrêté.', 1;
    SET @motif = CASE WHEN dbo.fn_texte_vide(@motif) = 1 THEN NULL ELSE LTRIM(RTRIM(@motif)) END;
    IF @motif IS NULL
        THROW 51245, N'Demande refusée : elle exige un motif, qui dit quel travail justifie de déverrouiller le dossier.', 1;
    IF LEN(@motif) > 580
        THROW 51247, N'Demande refusée : le motif tient en 580 caractères au plus.', 1;
    INSERT INTO dbo.demande_reouverture (entite, arrete, nature, motif, demande_par) VALUES (@entite, @arrete, 'DEVERROUILLAGE', @motif, @par);
    SELECT SCOPE_IDENTITY() AS demande_id,
           N'Déverrouillage du dossier de l''arrêté du ' + dbo.fn_date_ecran(@arrete) + N' demandé ; il attend la décision du chef de mission.' AS message;
END;

GO

