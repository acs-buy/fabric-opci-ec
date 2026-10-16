
-- pr_rouvrir_arrete : 1 refus
-- la reouverture perime la publication en vigueur de l'arrete, dans sa transaction

-- ------------------------------------------------------------------------------------------------- 2.5 : pr_rouvrir_arrete
-- Elle decide sur la demande : refus 50096, 50996, 50997, 50099, 50095, 50991, dans cet ordre (0.6) ; le renvoi, dont
-- l'inscription accorde la demande (garde de visa), la peremption O19, la forme du rapport a arreter de nouveau, la levee
-- du verrou s'il est pose et le renvoi de la revue si elle est visee (4 A), la marque des copies des documents perimes
-- (7 B), dans une seule transaction. Ni calcul de l'annexe, ni verrou d'entite.
CREATE   PROCEDURE dbo.pr_rouvrir_arrete
    @entite            VARCHAR (20),
    @arrete            VARCHAR (20),
    @demande_id        INT = NULL,
    @par               NVARCHAR (400),
    @documents_perimes INT = NULL OUTPUT,
    @verrou_leve       BIT = NULL OUTPUT,
    @revue_renvoyee    BIT = NULL OUTPUT,
    @copies_marquees   INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE), @auteur NVARCHAR (400), @motif NVARCHAR (800), @p VARCHAR (20), @m NVARCHAR (400);
    IF dbo.fn_decide_reouverture(@entite, @par, @le) = 0
        THROW 50096, N'Réouverture refusée : elle relève du chef de mission, qui a clôturé l''arrêté.', 1;
    IF @demande_id IS NULL
        THROW 50996, N'Réouverture refusée : elle se décide sur une demande, et aucune n''est désignée.', 1;
    SELECT @auteur = demande_par, @motif = motif FROM dbo.demande_reouverture
    WHERE id = @demande_id AND entite = @entite AND arrete = @arrete AND nature = 'REOUVERTURE' AND etat = 'EN_ATTENTE';
    IF @auteur IS NULL
        THROW 50997, N'Réouverture refusée : aucune demande de réouverture n''attend sur cet arrêté ; la réouverture suit une demande.', 1;
    IF @auteur = @par
        THROW 50099, N'Réouverture refusée : celui qui la demande ne peut pas la décider.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 0
        THROW 50095, N'Réouverture refusée : l''arrêté n''est pas validé pour le client, il n''y a rien à rouvrir.', 1;
    SET @p = dbo.fn_arrete_clos_posterieur(@entite, @arrete);
    IF @p IS NOT NULL
    BEGIN
        SET @m = N'Réouverture refusée : l''arrêté postérieur du ' + dbo.fn_date_ecran(@p) + N' est clos ; la réouverture commence par le dernier arrêté clos.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50991, @m, 1; END
    END;

    DECLARE @tc INT = @@TRANCOUNT, @maintenant DATETIME2 (3) = SYSUTCDATETIME();
    DECLARE @perimes TABLE (id INT PRIMARY KEY);
    BEGIN TRY
    BEGIN TRANSACTION;
    -- le renvoi ; la garde de visa accorde la demande dans cette transaction
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par, decide_le)
    VALUES ('CLOTURE', @entite + '|' + @arrete, @entite, @arrete, NULL, 'RENVOYE', N'Réouverture : ' + @motif, @auteur, @par, @maintenant);
    -- la peremption O19 de tous les documents en vigueur de l'arrete
    UPDATE dbo.document_produit
    SET perime_le = @maintenant,
        perime_motif = LEFT(N'Arrêté rouvert le ' + CONVERT(NVARCHAR (10), @maintenant, 103) + N' : ' + @motif
                          + N' Le document a été produit sur des comptes antérieurs à la réouverture.', 600)
    OUTPUT inserted.id INTO @perimes (id)
    WHERE entite = @entite AND arrete = @arrete AND perime_le IS NULL;
    SET @documents_perimes = (SELECT COUNT(*) FROM @perimes);
    -- 7 B : les copies chez le client des documents perimes sont marquees
    UPDATE dbo.copie_livrable SET perimee_le = @maintenant WHERE perimee_le IS NULL AND document_id IN (SELECT id FROM @perimes);
    SET @copies_marquees = @@ROWCOUNT;
    -- ecran 4, objet n° 10 : la VL publiee de l'arrete rouvert est perimee ; une VL corrigee se republie
    UPDATE dbo.publication_vl SET perimee_le = @maintenant WHERE entite = @entite AND arrete = @arrete AND perimee_le IS NULL;
    -- la forme de l'attestation est a arreter de nouveau
    UPDATE dbo.attestation SET arretee_par = NULL, arretee_le = NULL, produit_par = NULL, produit_le = NULL
    WHERE entite = @entite AND arrete = @arrete;
    -- 4 A : le verrou leve s'il est pose ; la revue renvoyee si elle est visee
    UPDATE dbo.dossier_verrou SET verrouille = 0, deverrouille_par = @par, deverrouille_le = @maintenant
    WHERE entite = @entite AND arrete = @arrete AND verrouille = 1;
    SET @verrou_leve = CASE WHEN @@ROWCOUNT > 0 THEN 1 ELSE 0 END;
    SET @revue_renvoyee = 0;
    IF dbo.fn_revue_visee(@entite, @arrete) = 1
    BEGIN
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par, decide_le)
        VALUES ('REVUE', @entite + '|' + @arrete, @entite, @arrete, NULL, 'RENVOYE', N'Réouverture : ' + @motif, @auteur, @par, @maintenant);
        SET @revue_renvoyee = 1;
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @demande_id AS demande_id, @documents_perimes AS documents_perimes, @verrou_leve AS verrou_leve, @revue_renvoyee AS revue_renvoyee,
           @copies_marquees AS copies_marquees,
           N'Arrêté du ' + dbo.fn_date_ecran(@arrete) + N' rouvert.' AS message;
END;

GO

