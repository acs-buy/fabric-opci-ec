-- --- 4. pr_ecran_accorder_reouverture ----------------------------------------------------------------------
-- : decide la demande en attente de l'arrete, quelle que soit sa nature. REOUVERTURE : inchangee, hors du texte
-- de 50988. DEVERROUILLAGE : role qui vise la revue (51248), arrete non valide pour le client (51249), dossier
-- verrouille (51250), revue visee (51251), juges sous le verrou d'entite (pr_ann_verrou) ;
-- visa REVUE RENVOYE, verrou leve et demande accordee dans la meme transaction.
CREATE   PROCEDURE dbo.pr_ecran_accorder_reouverture @entite VARCHAR (20), @arrete VARCHAR (20), @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE), @id INT, @auteur NVARCHAR (400), @nature VARCHAR (14), @motif NVARCHAR (800);
    SELECT @id = id, @auteur = demande_par, @nature = nature, @motif = motif FROM dbo.demande_reouverture
    WHERE entite = @entite AND arrete = @arrete AND etat = 'EN_ATTENTE';
    IF @nature = 'DEVERROUILLAGE'
    BEGIN
        IF dbo.fn_peut_viser_nature(@entite, @par, 'REVUE', @le) = 0
            THROW 51248, N'Décision refusée : le déverrouillage d''un dossier se décide par le chef de mission du dossier.', 1;
    END
    ELSE IF dbo.fn_decide_reouverture(@entite, @par, @le) = 0
        THROW 50987, N'Décision refusée : la réouverture d''un arrêté se décide par le chef de mission du dossier.', 1;
    IF @id IS NULL
        THROW 50988, N'Décision refusée : aucune demande n''attend sur cet arrêté.', 1;
    IF @auteur = @par AND @nature = 'DEVERROUILLAGE'
        THROW 50989, N'Décision refusée : vous avez demandé ce déverrouillage ; un autre membre habilité le décide.', 1;
    IF @auteur = @par
        THROW 50989, N'Décision refusée : vous avez demandé cette réouverture ; un autre membre habilité la décide.', 1;
    IF @nature = 'DEVERROUILLAGE'
    BEGIN
        DECLARE @maintenant DATETIME2 (3) = SYSUTCDATETIME(), @visa INT, @tc INT = @@TRANCOUNT;
        BEGIN TRY
        BEGIN TRANSACTION;
        -- le verrou d'entite de pr_valider_pour_client et de pr_viser_revue, pris avant les refus d'etat : une validation
        -- pour le client ou un visa de revue concurrents attendent ce commit, ou ont ete commites avant ces lectures
        EXEC dbo.pr_ann_verrou @entite = @entite;
        IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
            THROW 51249, N'Décision refusée : l''arrêté a été validé pour le client pendant l''attente ; écartez la demande, puis demandez la réouverture.', 1;
        IF NOT EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete AND verrouille = 1)
            THROW 51250, N'Décision refusée : le dossier de cet arrêté n''est plus verrouillé ; écartez la demande.', 1;
        IF dbo.fn_revue_visee(@entite, @arrete) = 0
            THROW 51251, N'Décision refusée : la revue de ce dossier n''est pas visée. Signaler ce refus à l''administrateur de la solution.', 1;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par, decide_le)
        VALUES ('REVUE', @entite + '|' + @arrete, @entite, @arrete, NULL, 'RENVOYE', N'Déverrouillage : ' + @motif, @auteur, @par, @maintenant);
        SET @visa = SCOPE_IDENTITY();
        UPDATE dbo.dossier_verrou SET verrouille = 0, deverrouille_par = @par, deverrouille_le = @maintenant
        WHERE entite = @entite AND arrete = @arrete AND verrouille = 1;
        -- n'ecrit que sur une demande encore en attente : une decision concurrente passee entre-temps rend 50988
        UPDATE dbo.demande_reouverture SET etat = 'ACCORDEE', decide_par = @par, decide_le = @maintenant, visa_id = @visa
        WHERE id = @id AND etat = 'EN_ATTENTE';
        IF @@ROWCOUNT = 0
            THROW 50988, N'Décision refusée : aucune demande n''attend sur cet arrêté.', 1;
        COMMIT;
        END TRY
        BEGIN CATCH
            IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            THROW;
        END CATCH;
        SELECT @id AS demande_id,
               N'Dossier de l''arrêté du ' + dbo.fn_date_ecran(@arrete) + N' déverrouillé : revue renvoyée, elle se reconclut avant un nouveau visa ; la demande '
             + dbo.fn_de(dbo.fn_nom_personne_ecran(@entite, @auteur)) + N' est accordée.' AS message;
        RETURN;
    END;
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

