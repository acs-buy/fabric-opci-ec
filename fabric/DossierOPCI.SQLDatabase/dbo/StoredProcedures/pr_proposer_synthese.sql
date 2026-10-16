
-- pr_proposer_synthese : 6 refus
-- ------------------------------------------------------------------ n° 9 : le refus d'une 2e proposition de synthese
-- Une synthese non perimee qui attend son visa refuse la proposition (50780) ; une synthese visee la refuse (50781) ; une
-- synthese renvoyee est perimee, et la nouvelle proposition s'inscrit.

-- --- 3 : O1, la proposition de la synthese --------------------------
-- 50077 : un lot de l'arrete est propose et non vise.
-- 50078 : un compte de classe 1 mouvemente sort du perimetre de l'actif
--         net, ce que la vue du script 46 mesure.
-- 50079 : la rationalisation ne boucle pas, ou n'est pas calculable.
-- 50080 : la valeur liquidative n'est pas calculable.
CREATE   PROCEDURE dbo.pr_proposer_synthese
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ref VARCHAR (30) = @entite + '|' + @arrete;

    -- Refus 1 : un lot attend le visa.
    DECLARE @lot INT = (SELECT TOP 1 l.id FROM dbo.lot_ecritures l
                        WHERE l.entite = @entite AND l.arrete = @arrete
                          AND l.statut = 'PROPOSE');
    IF @lot IS NOT NULL
    BEGIN
        DECLARE @m77 NVARCHAR (2000) =
            N'Synthèse refusée : le lot ' + CAST(@lot AS NVARCHAR (20))
            + N' est proposé et n''est pas visé. La synthèse porte sur un '
            + N'actif net arrêté : elle ne se propose pas tant qu''un lot '
            + N'peut encore changer les comptes.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour,
             refuse_le)
        VALUES ('pr_proposer_synthese', @entite, @arrete, @m77,
                N'Faire viser le lot par le chef de mission, puis proposer la synthèse.',
                @par, SYSUTCDATETIME());
        BEGIN SET @m77 = REPLACE(@m77, N'%', N'%%'); THROW 50077, @m77, 1; END
    END;

    -- Refus 2 : un compte de classe 1 hors perimetre de l'actif net.
    DECLARE @hors INT = (SELECT COUNT(*) FROM dbo.v_comptes_classe_1_hors_anr h
                         WHERE h.entite = @entite AND h.arrete = @arrete);
    IF @hors > 0
    BEGIN
        DECLARE @cpt NVARCHAR (400) =
            (SELECT STRING_AGG(CAST(h.compte_num AS NVARCHAR (MAX)), N', ')
             FROM dbo.v_comptes_classe_1_hors_anr h
             WHERE h.entite = @entite AND h.arrete = @arrete);
        DECLARE @m78 NVARCHAR (2000) =
            N'Synthèse refusée : ' + CAST(@hors AS NVARCHAR (10))
            + N' compte(s) de classe 1 sont mouvementés sans appartenir au '
            + N'périmètre de l''actif net : ' + @cpt
            + N'. Trancher leur rattachement avant de proposer la synthèse, '
            + N'faute de quoi l''actif net publié serait incomplet.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour,
             refuse_le)
        VALUES ('pr_proposer_synthese', @entite, @arrete, @m78,
                N'Rattacher ou écarter les comptes de classe 1 listés.',
                @par, SYSUTCDATETIME());
        BEGIN SET @m78 = REPLACE(@m78, N'%', N'%%'); THROW 50078, @m78, 1; END
    END;

    -- Refus 3 : la rationalisation ne boucle pas ou n'est pas calculable.
    DECLARE @boucle BIT, @ecart DECIMAL (19,2), @lecture NVARCHAR (300);
    SELECT @boucle = boucle, @ecart = ecart, @lecture = lecture
    FROM dbo.v_controle_rationalisation
    WHERE entite = @entite AND arrete = @arrete;
    IF @boucle IS NULL OR @boucle = 0
    BEGIN
        DECLARE @m79 NVARCHAR (2000) =
            N'Synthèse refusée : la rationalisation de l''actif net '
            + CASE WHEN @boucle IS NULL
                   THEN N'n''est pas calculable pour cet arrêté.'
                   ELSE N'ne boucle pas : écart de '
                        + FORMAT(@ecart, 'N2', 'fr-FR')
                        + N', au-delà du seuil de 1 000,00. ' + @lecture END
            + N' Lire la rationalisation poste par poste avant de proposer '
            + N'la synthèse.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour,
             refuse_le)
        VALUES ('pr_proposer_synthese', @entite, @arrete, @m79,
                N'Lever l''écart de rationalisation poste par poste.',
                @par, SYSUTCDATETIME());
        BEGIN SET @m79 = REPLACE(@m79, N'%', N'%%'); THROW 50079, @m79, 1; END
    END;

    -- Refus 4 : la valeur liquidative n'est pas calculable.
    IF NOT EXISTS (SELECT 1 FROM dbo.v_valeur_liquidative v
                   WHERE v.entite = @entite AND v.arrete = @arrete
                     AND v.valeur_liquidative IS NOT NULL)
    BEGIN
        DECLARE @m80 NVARCHAR (2000) =
            N'Synthèse refusée : la valeur liquidative n''est pas rendue '
            + N'pour cet arrêté. Vérifier le nombre de parts en circulation '
            + N'et les lots validés, puis proposer la synthèse.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, geste, refuse_pour,
             refuse_le)
        VALUES ('pr_proposer_synthese', @entite, @arrete, @m80,
                N'Saisir le nombre de parts, ou valider les lots manquants.',
                @par, SYSUTCDATETIME());
        BEGIN SET @m80 = REPLACE(@m80, N'%', N'%%'); THROW 50080, @m80, 1; END
    END;

    -- La proposition, portee par un visa a l'etat propose. La table des
    -- visas ne porte que des decisions : la proposition s'y inscrit donc
    -- comme une ligne dont le proposant est renseigne et la decision
    -- prise par le chef de mission plus tard, par pr_viser_synthese.
    DECLARE @s INT, @s_le DATETIME2, @decision VARCHAR (10);
    SELECT TOP (1) @s = s.id, @s_le = s.propose_le FROM dbo.synthese_proposee s
    WHERE s.entite = @entite AND s.arrete = @arrete AND s.perime_le IS NULL
    ORDER BY s.propose_le DESC, s.id DESC;
    IF @s IS NOT NULL
    BEGIN
        SELECT TOP (1) @decision = v.decision FROM dbo.visa v
        WHERE v.nature = 'SYNTHESE' AND v.objet_ref = @ref AND v.decide_le >= @s_le
        ORDER BY v.decide_le DESC, v.id DESC;
        IF @decision IS NULL
        BEGIN
            DECLARE @m80b NVARCHAR (2000) =
                N'Synthèse refusée : la synthèse proposée le ' + CONVERT(NVARCHAR (10), @s_le, 103)
                + N' attend le visa du chef de mission. La viser ou la renvoyer avant d''en proposer une autre.';
            INSERT INTO dbo.journal_refus
                (procedure_nom, entite, arrete, message, geste, refuse_pour,
                 refuse_le)
            VALUES ('pr_proposer_synthese', @entite, @arrete, @m80b,
                    N'Faire viser ou renvoyer la synthèse proposée.',
                    @par, SYSUTCDATETIME());
            BEGIN SET @m80b = REPLACE(@m80b, N'%', N'%%'); THROW 50780, @m80b, 1; END
        END;
        IF @decision = 'VISE'
        BEGIN
            DECLARE @m80c NVARCHAR (2000) =
                N'Synthèse refusée : la synthèse de cet arrêté est visée. Elle se périme au visa d''un lot postérieur ; une nouvelle synthèse se propose ensuite.';
            INSERT INTO dbo.journal_refus
                (procedure_nom, entite, arrete, message, geste, refuse_pour,
                 refuse_le)
            VALUES ('pr_proposer_synthese', @entite, @arrete, @m80c,
                    N'Aucune action : la synthèse visée vaut pour cet arrêté.',
                    @par, SYSUTCDATETIME());
            BEGIN SET @m80c = REPLACE(@m80c, N'%', N'%%'); THROW 50781, @m80c, 1; END
        END;
        -- renvoyee : elle est perimee, la nouvelle proposition la remplace
        UPDATE dbo.synthese_proposee
           SET perime_le = SYSUTCDATETIME(), perime_motif = N'Renvoyée par le chef de mission, proposée de nouveau.'
         WHERE id = @s;
    END;
    INSERT INTO dbo.synthese_proposee
            (entite, arrete, actif_net_rationalise, actif_net_calcule,
             ecart, valeur_liquidative, propose_par, propose_le)
        SELECT @entite, @arrete, r.actif_net_rationalise,
               r.actif_net_calcule, r.ecart, v.valeur_liquidative,
               @par, SYSUTCDATETIME()
        FROM dbo.v_controle_rationalisation r
        JOIN dbo.v_valeur_liquidative v ON v.entite = r.entite
                                       AND v.arrete = r.arrete
        WHERE r.entite = @entite AND r.arrete = @arrete;
END;

GO

