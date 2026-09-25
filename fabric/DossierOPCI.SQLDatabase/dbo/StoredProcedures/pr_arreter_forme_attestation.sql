

-- --- 4 : la procedure, qui admet une forme choisie ------------------
-- 50085 : la forme soumise n'est pas admise. Le message distingue le cas
--         ou elle se derive et celui ou l'expert-comptable la choisit.
-- 50098 : une forme choisie sur limitation des diligences exige un motif.
CREATE   PROCEDURE dbo.pr_arreter_forme_attestation
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @forme  VARCHAR (20),
    @par    NVARCHAR (400),
    @motif  NVARCHAR (800) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF dbo.fn_peut_viser_nature(@entite, @par, 'PUBLICATION',
                                CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m83 NVARCHAR (1200) =
            N'Forme refusée : l''attestation est signée par l''associé '
            + N'signataire, et lui seul en arrête la forme.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m83,
                N'Faire arrêter la forme par l''associé signataire.', @par,
                SYSUTCDATETIME());
        THROW 50083, @m83, 1;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl p
                   WHERE p.entite = @entite AND p.arrete = @arrete)
    BEGIN
        DECLARE @m84 NVARCHAR (1200) =
            N'Forme refusée : la valeur liquidative de cet arrêté n''est '
            + N'pas publiée. L''attestation porte sur des comptes arrêtés.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m84,
                N'Publier la valeur liquidative.', @par, SYSUTCDATETIME());
        THROW 50084, @m84, 1;
    END;

    DECLARE @derivee VARCHAR (20), @admises NVARCHAR (60), @limitation BIT;
    SELECT @derivee = forme_proposee, @admises = formes_admises,
           @limitation = limitation_des_diligences
    FROM dbo.v_forme_attestation_proposee
    WHERE entite = @entite AND arrete = @arrete;

    -- LE CAS DE LA LIMITATION DES DILIGENCES : la forme ne se derive pas,
    -- l'expert-comptable la choisit, et il motive son choix.
    IF @limitation = 1
    BEGIN
        IF @forme NOT IN ('AVEC_OBSERVATION', 'REFUS_ATTESTER')
        BEGIN
            DECLARE @m85a NVARCHAR (2000) =
                N'Forme refusée : aucune feuille de cycle n''est conclue '
                + N'pour cet arrêté. La NP 2300 traite ce cas : une '
                + N'limitation des diligences appelle une conclusion avec '
                + N'observation, paragraphe 20, ou un refus d''attester, '
                + N'paragraphe 21, selon l''importance de ses incidences. '
                + N'La forme sans observation est fermée.';
            INSERT INTO dbo.journal_refus
                (procedure_nom, entite, arrete, message, geste, refuse_pour,
                 refuse_le)
            VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m85a,
                    N'Choisir entre l''observation et le refus d''attester.',
                    @par, SYSUTCDATETIME());
            THROW 50085, @m85a, 1;
        END;
        IF @motif IS NULL OR LEN(LTRIM(@motif)) = 0
        BEGIN
            DECLARE @m98 NVARCHAR (1200) =
                N'Forme refusée : une forme arrêtée sur limitation des '
                + N'diligences exige un motif, qui dit quelles informations '
                + N'ou quels documents n''ont pas été reçus de l''entité.';
            INSERT INTO dbo.journal_refus
                (procedure_nom, entite, arrete, message, geste, refuse_pour,
                 refuse_le)
            VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m98,
                    N'Saisir le motif de la limitation.', @par,
                    SYSUTCDATETIME());
            THROW 50098, @m98, 1;
        END;
    END
    ELSE IF @forme <> @derivee
    BEGIN
        DECLARE @m85 NVARCHAR (2000) =
            N'Forme refusée : la forme de l''attestation se dérive de la '
            + N'plus sévère des conclusions des feuilles de travail. La '
            + N'forme dérivée est « ' + @derivee + N' ».';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_arreter_forme_attestation', @entite, @arrete, @m85,
                N'Arrêter la forme dérivée, ou conclure les feuilles.', @par,
                SYSUTCDATETIME());
        THROW 50085, @m85, 1;
    END;

    IF EXISTS (SELECT 1 FROM dbo.attestation
               WHERE entite = @entite AND arrete = @arrete)
        UPDATE dbo.attestation
        SET forme_proposee = @derivee, forme = @forme,
            motif_limitation = @motif,
            arretee_par = @par, arretee_le = SYSUTCDATETIME()
        WHERE entite = @entite AND arrete = @arrete;
    ELSE
        INSERT INTO dbo.attestation
            (entite, arrete, forme, forme_proposee, motif_limitation,
             arretee_par, arretee_le, produit_par, produit_le)
        VALUES (@entite, @arrete, @forme, @derivee, @motif, @par,
                SYSUTCDATETIME(), NULL, NULL);
END;

GO

