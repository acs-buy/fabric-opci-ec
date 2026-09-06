
CREATE   PROCEDURE dbo.pr_approuver_maintien
    @entite         VARCHAR (20),
    @arrete_conclu  VARCHAR (20),
    @decision       VARCHAR (10),     -- MAINTENU ou ROMPU
    @motif          NVARCHAR (800) = NULL,
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @statut VARCHAR (10), @cote VARCHAR (30), @propose NVARCHAR (400);
    SELECT @statut = statut, @cote = cote_questionnaire, @propose = cree_par
    FROM dbo.maintien_mission
    WHERE entite = @entite AND arrete_conclu = @arrete_conclu;

    IF @statut IS NULL
        THROW 50072,
            N'Approbation refusée : aucun maintien n''est ouvert pour cette entité et cet exercice.',
            1;
    IF @statut <> 'OUVERT'
        THROW 50072,
            N'Approbation refusée : ce maintien n''est plus au statut ouvert. Un maintien approuvé ne se réapprouve pas, un maintien refusé se reprend.',
            1;

    IF @propose = @par
    BEGIN
        DECLARE @m70 NVARCHAR (1200) =
            N'Approbation refusée : le maintien a été proposé par la même '
            + N'personne. La décision se prend par un autre que celui qui '
            + N'l''a préparée.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, geste,
             refuse_pour, refuse_le)
        VALUES ('pr_approuver_maintien', @entite, @arrete_conclu, @cote, @m70,
                N'Faire approuver par l''associé signataire.', @par,
                SYSUTCDATETIME());
        THROW 50070, @m70, 1;
    END;

    IF dbo.fn_peut_viser_nature(@entite, @par, 'MAINTIEN',
                             CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m71 NVARCHAR (1200) =
            N'Approbation refusée : cette personne n''a pas, sur cette '
            + N'entité, le rôle que la nature « maintien » exige. '
            + N'L''examen périodique de la poursuite d''une mission '
            + N'récurrente relève de l''associé, article 150 alinéa 2 du '
            + N'code de déontologie.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, geste,
             refuse_pour, refuse_le)
        VALUES ('pr_approuver_maintien', @entite, @arrete_conclu, @cote, @m71,
                N'Faire approuver par l''associé.', @par, SYSUTCDATETIME());
        THROW 50071, @m71, 1;
    END;

    DECLARE @sans NVARCHAR (20), @reste INT;
    SELECT @reste = COUNT(*) FROM dbo.ref_question q
    WHERE q.phase = 'MAINTIEN' AND q.obligatoire = 1
      AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq
                      WHERE fq.cote = @cote AND fq.question_id = q.id
                        AND (fq.reponse IS NOT NULL
                             OR fq.reponse_valeur IS NOT NULL));
    IF @reste > 0
    BEGIN
        SELECT TOP 1 @sans = q.reference FROM dbo.ref_question q
        WHERE q.phase = 'MAINTIEN' AND q.obligatoire = 1
          AND NOT EXISTS (SELECT 1 FROM dbo.feuille_question fq
                          WHERE fq.cote = @cote AND fq.question_id = q.id
                            AND (fq.reponse IS NOT NULL
                                 OR fq.reponse_valeur IS NOT NULL))
        ORDER BY q.ordre;
        DECLARE @m69 NVARCHAR (2000) =
            N'Approbation refusée : ' + CAST(@reste AS NVARCHAR (10))
            + N' question(s) obligatoire(s) du questionnaire de maintien '
            + N'sont sans réponse, dont ' + @sans + N'. Répondre à toutes '
            + N'les questions obligatoires, puis approuver.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, question_reference,
             message, geste, refuse_pour, refuse_le)
        VALUES ('pr_approuver_maintien', @entite, @arrete_conclu, @cote,
                @sans, @m69,
                N'Répondre aux questions obligatoires sans réponse.', @par,
                SYSUTCDATETIME());
        THROW 50069, @m69, 1;
    END;

    IF @decision NOT IN ('MAINTENU', 'ROMPU')
        THROW 50072,
            N'Approbation refusée : la décision doit être « maintenu » ou « rompu ».',
            1;
    IF @decision = 'ROMPU' AND @motif IS NULL
        THROW 50072,
            N'Approbation refusée : la rupture exige un motif. Les articles 156 et 157 du code de déontologie n''admettent la fin d''une mission que pour des motifs justes et raisonnables, ou en cas de conflit d''intérêts.',
            1;

    UPDATE dbo.maintien_mission
    SET statut = CASE WHEN @decision = 'MAINTENU' THEN 'APPROUVE'
                      ELSE 'REFUSE' END,
        decision = @decision, motif = @motif,
        approuve_par = @par, approuve_le = SYSUTCDATETIME()
    WHERE entite = @entite AND arrete_conclu = @arrete_conclu;

    INSERT INTO dbo.visa
        (nature, objet_ref, entite, arrete, cycle, decision, motif,
         propose_par, decide_par, decide_le)
    VALUES ('MAINTIEN', @entite + '|' + @arrete_conclu, @entite,
            @arrete_conclu, NULL,
            CASE WHEN @decision = 'MAINTENU' THEN 'VISE' ELSE 'RENVOYE' END,
            @motif, @propose, @par, SYSUTCDATETIME());
END;

GO

