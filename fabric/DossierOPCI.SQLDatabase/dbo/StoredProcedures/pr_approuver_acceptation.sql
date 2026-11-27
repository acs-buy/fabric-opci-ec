
-- pr_approuver_acceptation : 3 refus
CREATE PROCEDURE dbo.pr_approuver_acceptation
    @entite    VARCHAR (20),
    @decision  VARCHAR (10),          -- ACCEPTEE ou REFUSEE
    @motif     NVARCHAR (800) = NULL,
    @par       NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @statut VARCHAR (10), @cote VARCHAR (30), @propose NVARCHAR (400);
    SELECT @statut = statut, @cote = cote_questionnaire, @propose = cree_par
    FROM dbo.acceptation_mission WHERE entite = @entite;

    IF @statut IS NULL
        THROW 50072,
            N'Approbation refusée : aucune acceptation n''est ouverte pour cette entité. Ouvrir l''acceptation, répondre au questionnaire, puis approuver.',
            1;

    IF @statut = 'APPROUVE'
        THROW 50072,
            N'Approbation refusée : l''acceptation de cette entité est déjà approuvée. Pour la reprendre, passer par la reprise.',
            1;

    IF @statut = 'REFUSE'
        THROW 50072,
            N'Approbation refusée : l''acceptation de cette entité est au statut refusé. L''action attendue est la reprise, qui exige un motif et remet le dossier à l''état ouvert.',
            1;

    -- Le proposant ne s'approuve pas lui-meme.
    IF @propose = @par
    BEGIN
        DECLARE @m70 NVARCHAR (1200) =
            N'Approbation refusée : l''acceptation a été proposée par la '
            + N'même personne. La décision d''accepter une mission se prend '
            + N'par un autre que celui qui l''a préparée. Faire approuver '
            + N'par l''associé signataire.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_approuver_acceptation', @entite, @cote, @m70,
                N'Faire approuver par l''associé signataire.', @par,
                SYSUTCDATETIME());
        BEGIN SET @m70 = REPLACE(@m70, N'%', N'%%'); THROW 50070, @m70, 1; END
    END;

    -- Le role que la nature exige, lu de dbo.role_nature_visa.
    IF dbo.fn_peut_viser_nature(@entite, @par, 'ACCEPTATION',
                             CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m71 NVARCHAR (1200) =
            N'Décision refusée : vous ne tenez pas, sur cette entité, le rôle qui décide de l''acceptation. Faire décider par l''associé.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_approuver_acceptation', @entite, @cote, @m71,
                N'Faire approuver par l''associé.', @par, SYSUTCDATETIME());
        BEGIN SET @m71 = REPLACE(@m71, N'%', N'%%'); THROW 50071, @m71, 1; END
    END;

    -- Le questionnaire complet. Une question obligatoire de la phase sans
    -- reponse arrete l'approbation, et le refus NOMME la premiere.
    DECLARE @sans NVARCHAR (20), @sans_enonce NVARCHAR (400), @reste INT;
    SELECT @reste = COUNT(*) FROM dbo.ref_question q
    WHERE q.phase = 'ACCEPT' AND q.obligatoire = 1
      AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq
                      WHERE fq.cote = @cote AND fq.question_id = q.id
                        AND (fq.reponse IS NOT NULL
                             OR fq.reponse_valeur IS NOT NULL));
    IF @reste > 0
    BEGIN
        SELECT TOP 1 @sans = q.reference, @sans_enonce = LEFT(q.enonce, 121)
        FROM dbo.ref_question q
        WHERE q.phase = 'ACCEPT' AND q.obligatoire = 1
          AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq
                          WHERE fq.cote = @cote AND fq.question_id = q.id
                            AND (fq.reponse IS NOT NULL
                                 OR fq.reponse_valeur IS NOT NULL))
        ORDER BY q.ordre;
        DECLARE @m69 NVARCHAR (2000) =
            N'Décision refusée : ' + CAST(@reste AS NVARCHAR (10)) + CASE WHEN @reste > 1 THEN N' questions obligatoires sont sans réponse, dont ' ELSE N' question obligatoire est sans réponse : ' END + @sans + N' « ' + CASE WHEN LEN(@sans_enonce + N'.') - 1 > 120 THEN RTRIM(LEFT(@sans_enonce, 119)) + N'…' ELSE @sans_enonce END + N' ». ' + CASE WHEN @reste > 1 THEN N'Répondez à toutes, puis décidez.' ELSE N'Répondez-y, puis décidez.' END;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, cote, question_reference, message, geste,
             refuse_pour, refuse_le)
        VALUES ('pr_approuver_acceptation', @entite, @cote, @sans, @m69,
                N'Répondre aux questions obligatoires sans réponse.', @par,
                SYSUTCDATETIME());
        BEGIN SET @m69 = REPLACE(@m69, N'%', N'%%'); THROW 50069, @m69, 1; END
    END;

    IF @decision NOT IN ('ACCEPTEE', 'REFUSEE')
        THROW 50072,
            N'Approbation refusée : la décision doit être « acceptée » ou « refusée ». La valeur « en attente » est celle du dossier ouvert, elle ne s''approuve pas.',
            1;

    IF @decision = 'REFUSEE' AND @motif IS NULL
        THROW 50072,
            N'Refus non enregistré : refuser une mission exige un motif. Saisir le motif du refus, puis refuser de nouveau.',
            1;

    UPDATE dbo.acceptation_mission
    SET statut = CASE WHEN @decision = 'ACCEPTEE' THEN 'APPROUVE'
                      ELSE 'REFUSE' END,
        decision = @decision, motif = @motif,
        approuve_par = @par, approuve_le = SYSUTCDATETIME()
    WHERE entite = @entite;

    INSERT INTO dbo.visa
        (nature, objet_ref, entite, arrete, cycle, decision, motif,
         propose_par, decide_par, decide_le)
    SELECT 'ACCEPTATION', @entite, @entite,
           -- L'acceptation ne porte pas sur un arrete : le premier arrete
           -- de l'entite au referentiel sert de reference, la table des
           -- visas l'exigeant.
           (SELECT MIN(r.arrete) FROM dbo.ref_arrete r
            WHERE r.entite = @entite AND r.nature_technique = 'MISSION'),
           NULL,
           CASE WHEN @decision = 'ACCEPTEE' THEN 'VISE' ELSE 'RENVOYE' END,
           @motif, @propose, @par, SYSUTCDATETIME();
END;

GO

