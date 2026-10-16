
CREATE   PROCEDURE dbo.pr_ecran_accorder_reouverture @entite VARCHAR (20), @arrete VARCHAR (20), @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE), @id INT, @auteur NVARCHAR (400);
    IF dbo.fn_decide_reouverture(@entite, @par, @le) = 0
        THROW 50987, N'Décision refusée : la réouverture d''un arrêté se décide par le chef de mission du dossier.', 1;
    SELECT @id = id, @auteur = demande_par FROM dbo.demande_reouverture
    WHERE entite = @entite AND arrete = @arrete AND nature = 'REOUVERTURE' AND etat = 'EN_ATTENTE';
    IF @id IS NULL
        THROW 50988, N'Décision refusée : aucune demande de réouverture n''attend sur cet arrêté.', 1;
    IF @auteur = @par
        THROW 50989, N'Décision refusée : vous avez demandé cette réouverture ; un autre membre habilité la décide.', 1;
    DECLARE @n INT, @v BIT, @r BIT, @c INT;
    DECLARE @sortie TABLE (demande_id INT, documents_perimes INT, verrou_leve BIT, revue_renvoyee BIT, copies_marquees INT, message NVARCHAR (400));
    INSERT INTO @sortie EXEC dbo.pr_rouvrir_arrete @entite = @entite, @arrete = @arrete, @demande_id = @id, @par = @par;
    SELECT @n = documents_perimes, @v = verrou_leve, @r = revue_renvoyee, @c = copies_marquees FROM @sortie;
    DECLARE @pub DATETIME2 (3) = (SELECT MAX(publiee_le) FROM dbo.publication_client WHERE entite = @entite AND arrete = @arrete AND etat = 'PUBLIEE');
    SELECT @id AS demande_id,
           N'Arrêté du ' + dbo.fn_date_ecran(@arrete) + N' rouvert : visa de clôture renvoyé, '
         + CASE WHEN @n = 0 THEN N'aucun document à périmer' WHEN @n = 1 THEN N'1 document périmé' ELSE CAST(@n AS NVARCHAR (10)) + N' documents périmés' END
         + CASE WHEN @v = 1 THEN N', verrou levé' ELSE N'' END
         + CASE WHEN @r = 1 THEN N', revue renvoyée' ELSE N'' END
         + N' ; la demande ' + dbo.fn_de(dbo.fn_nom_personne_ecran(@entite, @auteur)) + N' est accordée. '
         + CASE WHEN @pub IS NOT NULL THEN N'Rapport client : la publication du ' + CONVERT(NVARCHAR (10), @pub, 103) + N' reste en ligne jusqu''à la prochaine publication.'
                ELSE N'Rapport client : arrêté non publié, rien ne change pour le client.' END AS message;
END;

GO

