

-- 6. L'ARRET DE LA FORME. Controles dans l'ordre du contrat : 50083, 50632, 50630, regles de l'entite (50628, 50629,
-- 50631), 50084, puis pour une forme d'attestation 50085 et 50098 sur la forme d'attestation derivee. Tout arret
-- perime, dans la meme transaction, la derniere version non perimee du rapport de l'arrete.
CREATE   PROCEDURE dbo.pr_arreter_forme_attestation
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @forme  VARCHAR (20),
    @par    NVARCHAR (400),
    @motif  NVARCHAR (800) = NULL,
    @motif_considerations NVARCHAR (800) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (2000), @soumise BIT, @derivee VARCHAR (20), @limitation BIT, @proposee VARCHAR (20),
            @ancienne VARCHAR (20), @maintenant DATETIME2 (3) = SYSUTCDATETIME(), @perimes INT = 0;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    SET @motif_considerations = NULLIF(LTRIM(RTRIM(@motif_considerations)), N'');

    IF dbo.fn_peut_viser_nature(@entite, @par, 'PUBLICATION', CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        SET @m = N'Forme refusée : le rapport de l''expert-comptable est signé par l''associé signataire, et lui seul en arrête la forme.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m, N'Faire arrêter la forme par l''associé signataire.', @par, SYSUTCDATETIME());
        THROW 50083, @m, 1;
    END;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        THROW 50632, N'Forme refusée : l''arrêté est validé pour le client ; un changement de forme suppose sa réouverture.', 1;
    IF @forme IS NULL OR @forme NOT IN ('COMPTE_RENDU_TRAVAUX', 'SANS_OBSERVATION', 'AVEC_OBSERVATION', 'IMPOSSIBILITE')
    BEGIN
        SET @m = N'Forme refusée : ' + ISNULL(@forme, N'(vide)') + N' n''est pas une forme du rapport de l''expert-comptable ; formes : COMPTE_RENDU_TRAVAUX, SANS_OBSERVATION, AVEC_OBSERVATION, IMPOSSIBILITE.';
        THROW 50630, @m, 1;
    END;

    SELECT @soumise = CASE WHEN soumise_commissariat_comptes = 1 THEN 1 ELSE 0 END FROM dbo.ref_entite WHERE code = @entite;
    IF @soumise = 1
    BEGIN
        IF @forme = 'COMPTE_RENDU_TRAVAUX' AND (@motif_considerations IS NOT NULL OR @motif IS NOT NULL)
            THROW 50629, N'Forme refusée : un motif de considérations particulières ne se saisit qu''avec une attestation, pour une entité soumise au commissariat aux comptes ; le compte rendu de travaux ne porte aucun motif.', 1;
        IF @forme <> 'COMPTE_RENDU_TRAVAUX' AND @motif_considerations IS NULL
        BEGIN
            SET @m = N'Forme refusée : l''entité ' + @entite + N' est soumise au commissariat aux comptes ; son rapport est un compte rendu de travaux (NP 2300, A10). Une attestation n''y est admise qu''avec le motif des considérations particulières qui la justifient.';
            THROW 50628, @m, 1;
        END;
    END
    ELSE
    BEGIN
        IF @forme = 'COMPTE_RENDU_TRAVAUX'
        BEGIN
            SET @m = N'Forme refusée : le compte rendu de travaux est réservé à une entité soumise au commissariat aux comptes ; pour l''entité ' + @entite + N', cet indicateur est à 0 ou à remplir.';
            THROW 50631, @m, 1;
        END;
        IF @motif_considerations IS NOT NULL
            THROW 50629, N'Forme refusée : un motif de considérations particulières ne se saisit qu''avec une attestation, pour une entité soumise au commissariat aux comptes ; le compte rendu de travaux ne porte aucun motif.', 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl p WHERE p.entite = @entite AND p.arrete = @arrete)
    BEGIN
        SET @m = N'Forme refusée : la valeur liquidative de cet arrêté n''est pas publiée. Le rapport de l''expert-comptable porte sur des comptes arrêtés.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m, N'Publier la valeur liquidative.', @par, SYSUTCDATETIME());
        THROW 50084, @m, 1;
    END;

    SELECT @derivee = forme_attestation_derivee, @limitation = limitation_des_diligences, @proposee = forme_proposee
    FROM dbo.v_forme_attestation_proposee WHERE entite = @entite AND arrete = @arrete;

    IF @forme <> 'COMPTE_RENDU_TRAVAUX'
    BEGIN
        IF @limitation = 1
        BEGIN
            IF @forme NOT IN ('AVEC_OBSERVATION', 'IMPOSSIBILITE')
            BEGIN
                SET @m = N'Forme refusée : aucune feuille de cycle n''est conclue pour cet arrêté. La NP 2300 traite ce cas : une limitation des diligences appelle une conclusion avec observation, paragraphe 20, ou un refus d''attester, paragraphe 21, selon l''importance de ses incidences. La forme sans observation est fermée.';
                INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
                VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m, N'Choisir entre l''observation et le refus d''attester.', @par, SYSUTCDATETIME());
                THROW 50085, @m, 1;
            END;
            IF @motif IS NULL
            BEGIN
                SET @m = N'Forme refusée : une forme arrêtée sur limitation des diligences exige un motif, qui dit quelles informations ou quels documents n''ont pas été reçus de l''entité.';
                INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
                VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m, N'Saisir le motif de la limitation.', @par, SYSUTCDATETIME());
                THROW 50098, @m, 1;
            END;
        END
        ELSE IF @forme <> @derivee
        BEGIN
            SET @m = N'Forme refusée : la forme d''attestation se dérive de la plus sévère des conclusions des feuilles de travail. La forme dérivée est « ' + @derivee + N' ».';
            INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
            VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m, N'Arrêter la forme dérivée, ou conclure les feuilles.', @par, SYSUTCDATETIME());
            THROW 50085, @m, 1;
        END;
    END;

    SELECT @ancienne = forme FROM dbo.attestation WHERE entite = @entite AND arrete = @arrete AND arretee_le IS NOT NULL;
    BEGIN TRANSACTION;
    IF EXISTS (SELECT 1 FROM dbo.attestation WHERE entite = @entite AND arrete = @arrete)
        UPDATE dbo.attestation
        SET forme_proposee = @proposee, forme = @forme,
            motif_limitation = CASE WHEN @forme = 'COMPTE_RENDU_TRAVAUX' THEN NULL ELSE @motif END,
            motif_considerations_particulieres = CASE WHEN @soumise = 1 AND @forme <> 'COMPTE_RENDU_TRAVAUX' THEN @motif_considerations END,
            arretee_par = @par, arretee_le = @maintenant
        WHERE entite = @entite AND arrete = @arrete;
    ELSE
        INSERT INTO dbo.attestation (entite, arrete, forme, forme_proposee, motif_limitation, motif_considerations_particulieres,
                                     arretee_par, arretee_le, produit_par, produit_le)
        VALUES (@entite, @arrete, @forme, @proposee, CASE WHEN @forme = 'COMPTE_RENDU_TRAVAUX' THEN NULL ELSE @motif END,
                CASE WHEN @soumise = 1 AND @forme <> 'COMPTE_RENDU_TRAVAUX' THEN @motif_considerations END,
                @par, @maintenant, NULL, NULL);
    -- le rapport produit avant cet arret ne porte plus la forme arretee : il passe perime, jamais supprime
    UPDATE dbo.document_produit
    SET perime_le = @maintenant,
        perime_motif = N'Périmé par l''arrêt de la forme du rapport : ' + ISNULL(@ancienne, N'aucune forme arrêtée') + N' remplacée par ' + @forme
                     + N', par ' + @par + N', le ' + CONVERT(NVARCHAR (19), @maintenant, 120) + N' UTC.'
    WHERE entite = @entite AND arrete = @arrete AND livrable = 'ATTESTATION' AND perime_le IS NULL;
    SET @perimes = @@ROWCOUNT;
    COMMIT;

    SELECT @forme AS forme, @proposee AS forme_proposee, @perimes AS documents_perimes,
           N'Forme du rapport arrêtée : ' + @forme
         + CASE WHEN @perimes > 0 THEN N' ; ' + CAST(@perimes AS NVARCHAR (12)) + N' fichier(s) du rapport produit avant cet arrêt passent périmés.' ELSE N'.' END AS message;
END;

GO

