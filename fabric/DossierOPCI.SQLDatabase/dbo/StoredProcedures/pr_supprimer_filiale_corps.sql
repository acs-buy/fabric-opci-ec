-- --- supprimer une filiale, ou retirer son lien quand l'entite reste -----------------------------------
-- pr_supprimer_filiale_corps : 1 refus
-- pr_supprimer_filiale : le corps d'origine, renomme
-- Les arretes HORS_MISSION de la filiale qu'aucun autre vehicule ne tient a la meme date partent avec elle, apres
-- un dernier jugement de chacun par pr_arrete_porte_travail (toutes les cles, lues au catalogue) ; un travail trouve
-- leve 50218, qui nomme l'arrete et le travail.
-- Quand l'entite reste (cliente du cabinet ou tenue par un autre vehicule), seul le lien part : le refus
-- dit « Le lien de <client> avec la filiale <code> ... ne se retire pas », et role_mission et demande_espace_client de
-- l'entite restent. Les arretes retires viennent de dbo.fn_lien_arretes, la meme source que la vue.
CREATE PROCEDURE dbo.pr_supprimer_filiale_corps
    @client   VARCHAR (20),
    @code     VARCHAR (20),
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_mere = @client AND entite_fille = @code)
        THROW 50216, N'Cette entité n''est pas une filiale de ce client.', 1;

    DECLARE @arretes INT, @feuilles INT, @pieces INT, @ecritures INT, @comptes INT, @detentions INT, @supprimable BIT, @denomination NVARCHAR (400);
    DECLARE @m NVARCHAR (1000), @tete NVARCHAR (400);
    -- l'entite reste-t-elle apres le retrait du lien ? (meme regle que la vue)
    DECLARE @reste BIT = CASE WHEN EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @code AND est_client = 1)
                                OR EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_fille = @code AND entite_mere <> @client)
                              THEN 1 ELSE 0 END;
    SET @tete = CASE WHEN @reste = 0
                     THEN N'La filiale ' + @code + N' porte des données de mission et ne se supprime pas'
                     ELSE N'Le lien de ' + @client + N' avec la filiale ' + @code + N' porte des données de mission et ne se retire pas' END;
    SELECT @arretes = arretes, @feuilles = feuilles, @pieces = pieces, @ecritures = ecritures, @comptes = comptes,
           @detentions = detentions, @supprimable = supprimable, @denomination = denomination
      FROM dbo.v_filiale_dependances WHERE entite_mere = @client AND entite_fille = @code;
    IF @supprimable = 0
    BEGIN
        SET @m = @tete + N' : '
            + CASE WHEN @arretes > 0 THEN CAST(@arretes AS NVARCHAR (10)) + N' arrêté(s), ' ELSE N'' END
            + CASE WHEN @feuilles > 0 THEN CAST(@feuilles AS NVARCHAR (10)) + N' feuille(s), ' ELSE N'' END
            + CASE WHEN @pieces > 0 THEN CAST(@pieces AS NVARCHAR (10)) + N' pièce(s), ' ELSE N'' END
            + CASE WHEN @ecritures > 0 THEN CAST(@ecritures AS NVARCHAR (10)) + N' écriture(s) ou import(s), ' ELSE N'' END
            + CASE WHEN @comptes > 0 THEN CAST(@comptes AS NVARCHAR (10)) + N' compte(s), ' ELSE N'' END
            + CASE WHEN @detentions > 0 THEN CAST(@detentions AS NVARCHAR (10)) + N' détention(s) à un arrêté, ' ELSE N'' END;
        IF RIGHT(@m, 2) = N', '
            SET @m = LEFT(@m, LEN(@m) - 1) + N'. Sa sortie du groupe se constate par la détention à l''arrêté suivant.';
        ELSE
        BEGIN
            -- aucun des comptes ci-dessus ; la donnee qui retient la ligne d'entite, nommee
            DECLARE @donnee NVARCHAR (128);
            EXEC dbo.pr_entite_porte_donnees @code, @donnee OUTPUT;
            SET @m = @tete + N' (' + ISNULL(@donnee, N'données liées') + N'). Sa sortie du groupe se constate par la détention à l''arrêté suivant.';
        END;
        INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_supprimer_filiale', @code, NULL, @m, N'Constater la sortie par la détention, ne pas supprimer.', @par, SYSUTCDATETIME());
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50218, @m, 1; END
    END;

    -- les arretes nus de la filiale, jugés un par un avant toute ecriture, lus par fn_lien_arretes,
    -- jugés s'ils comptent pour le lien (compte = 1), retirés s'ils ne sont pas partagés (partage = 0)
    DECLARE @ar TABLE (arrete VARCHAR (20) PRIMARY KEY, partage BIT NOT NULL);
    INSERT INTO @ar (arrete, partage)
    SELECT la.arrete, la.partage FROM dbo.fn_lien_arretes(@client, @code) la WHERE la.compte = 1;
    DECLARE @a VARCHAR (20), @t BIT, @trouve NVARCHAR (128), @k CURSOR;
    SET @k = CURSOR FAST_FORWARD FOR SELECT arrete FROM @ar ORDER BY arrete;
    OPEN @k; FETCH NEXT FROM @k INTO @a;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_arrete_porte_travail @code, @a, @t OUTPUT, @trouve OUTPUT;
        IF @t = 1
        BEGIN
            CLOSE @k; DEALLOCATE @k;
            SET @m = @tete + N' : l''arrêté du '
                   + ISNULL(CONVERT(NVARCHAR (10), TRY_CAST(@a AS DATE), 103), @a) + N' porte des travaux'
                   + ISNULL(N' (' + @trouve + N')', N'') + N'. Sa sortie du groupe se constate par la détention à l''arrêté suivant.';
            INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
            VALUES ('pr_supprimer_filiale', @code, NULL, @m, N'Constater la sortie par la détention, ne pas supprimer.', @par, SYSUTCDATETIME());
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50218, @m, 1; END
        END;
        FETCH NEXT FROM @k INTO @a;
    END;
    CLOSE @k; DEALLOCATE @k;
    -- quand la ligne d'entite partira, aucune autre donnee ne doit la referencer (sinon 547
    -- en anglais au DELETE) ; jugee au catalogue par pr_entite_porte_donnees, refus 50218 qui nomme la donnee.
    IF @reste = 0
    BEGIN
        EXEC dbo.pr_entite_porte_donnees @code, @trouve OUTPUT;
        IF @trouve IS NOT NULL
        BEGIN
            SET @m = @tete + N' (' + @trouve + N'). Sa sortie du groupe se constate par la détention à l''arrêté suivant.';
            INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
            VALUES ('pr_supprimer_filiale', @code, NULL, @m, N'Constater la sortie par la détention, ne pas supprimer.', @par, SYSUTCDATETIME());
            BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50218, @m, 1; END
        END;
    END;

    BEGIN TRY
    BEGIN TRANSACTION;
    DELETE dbo.ref_arrete WHERE entite = @code AND arrete IN (SELECT arrete FROM @ar WHERE partage = 0);
    -- les roles et la demande d'espace de l'entite ne partent qu'avec elle
    IF @reste = 0
    BEGIN
        DELETE dbo.role_mission WHERE entite = @code;
        DELETE dbo.demande_espace_client WHERE entite = @code;
    END;
    DELETE dbo.eligibilite_participation WHERE entite_mere = @client AND entite_fille = @code;
    -- la ligne d'entite part si aucun autre client ne la detient
    IF NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_fille = @code)
        DELETE dbo.ref_entite WHERE code = @code AND est_client = 0;
    INSERT INTO dbo.journal_perimetre (entite_mere, entite_fille, action, detail, fait_par)
    VALUES (@client, @code, 'SUPPRESSION', N'retirée du périmètre ; ' + @denomination, @par);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @code AS filiale, N'Filiale ' + @code + N' (' + @denomination + N') retirée du périmètre de ' + @client + N'.' AS message;
END;

GO

