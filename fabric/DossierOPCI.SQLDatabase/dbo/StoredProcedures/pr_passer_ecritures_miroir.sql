
-- --- 2 : le passage, a blanc par defaut -----------------------------
CREATE   PROCEDURE dbo.pr_passer_ecritures_miroir
    @arrete   VARCHAR (20),
    @natures  NVARCHAR (200) = NULL,   -- NULL pour les 3
    @a_blanc  BIT            = 1,      -- 1 : calcule et n'ecrit rien
    @par      NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE arrete = @arrete)
        THROW 50078, N'Arrêté inconnu : les écritures miroir se passent sur un arrêté existant.', 1;

    DECLARE @qui NVARCHAR (400) = ISNULL(@par, SUSER_SNAME());

    -- L'ACTIF NET AVANT, releve pour etre compare apres.
    DECLARE @avant TABLE (entite VARCHAR (20), actif_net DECIMAL (19,2));
    INSERT INTO @avant SELECT entite, actif_net_reevalue
    FROM dbo.v_anr_entite WHERE arrete = @arrete;

    -- CE QUI SERA PASSE, arrete une fois pour toutes avant d'ecrire.
    DECLARE @a_passer TABLE (
        flux_id INT, nature VARCHAR (20), entite VARCHAR (20),
        compte VARCHAR (20), sens VARCHAR (10), montant DECIMAL (19,2),
        compte_tresorerie VARCHAR (20), code_actif VARCHAR (20),
        plafonne BIT, lecture NVARCHAR (400));
    INSERT INTO @a_passer
    SELECT flux_id, nature, entite, compte, sens, montant_retenu,
           compte_tresorerie, code_actif, plafonne, lecture
    FROM dbo.v_ecriture_miroir_a_passer
    WHERE arrete = @arrete
      AND (@natures IS NULL
           OR nature IN (SELECT TRIM(value) FROM STRING_SPLIT(@natures, ',')))
      AND montant_retenu > 0
      -- Un pret sans compte de tresorerie crediteur n'a rien a
      -- reclasser : la vue le dit, la procedure l'ecarte.
      AND NOT (nature = 'DIVIDENDE' AND compte_tresorerie IS NULL);

    IF @a_blanc = 1
    BEGIN
        SELECT N'A BLANC, RIEN N''EST ECRIT' AS mode,
               nature, sens, COUNT(*) AS ecritures,
               SUM(montant) AS montant,
               SUM(CAST(plafonne AS INT)) AS plafonnes
        FROM @a_passer GROUP BY nature, sens ORDER BY nature, sens;
        SELECT TOP 12 entite, nature, sens, compte, compte_tresorerie,
               montant, plafonne, LEFT(lecture, 62) AS lecture
        FROM @a_passer ORDER BY nature, entite;
        RETURN;
    END;

    -- L'ECRITURE, ENTITE PAR ENTITE, DANS UNE TRANSACTION. Les essais du
    -- 05/09/2026 ont laisse 7 lots orphelins et 11 feuilles inutiles :
    -- chaque refus de contrainte survenait APRES la creation du lot, et
    -- rien ne l'annulait. Un lot sans ecriture est un dechet qu'aucun
    -- controle ne rattrape, et le rejeu en aurait cree a chaque essai.
    DECLARE @entite VARCHAR (20), @lot INT, @n INT = 0;
    BEGIN TRANSACTION;
    BEGIN TRY
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT entite FROM @a_passer ORDER BY entite;
    OPEN c;
    FETCH NEXT FROM c INTO @entite;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- LA FEUILLE QUI JUSTIFIE LE LOT. Son origine est HUMAINE :
        -- elle accompagne une ecriture DECIDEE, que le dossier assume,
        -- non un calcul que le moteur refera. L'empreinte
        -- derive de ce qu'elle porte, entite, arrete et montant total,
        -- si bien que 2 executions sur des donnees differentes ne
        -- rendent pas la meme empreinte.
        DECLARE @cote VARCHAR (30) = 'MIR-' + @entite + '-' + @arrete;
        DECLARE @total DECIMAL (19,2) =
            (SELECT SUM(montant) FROM @a_passer WHERE entite = @entite);
        IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
            INSERT INTO dbo.feuille_travail
                (cote, cycle, arrete, entite, modele_code, origine,
                 nom_fichier, chemin_coffre, empreinte_sha256, conclusion,
                 preparateur, prepare_le)
            VALUES (@cote, 'PART', @arrete, @entite, NULL, 'HUMAINE',
                    N'miroir_intragroupe_' + @entite + N'_' + @arrete + N'.csv',
                    N'/Coffre/' + @entite + N'/' + @arrete
                      + N'/feuilles/miroir_intragroupe.csv',
                    CONVERT(CHAR (64), HASHBYTES('SHA2_256',
                        N'miroir|' + @entite + N'|' + @arrete + N'|'
                        + CONVERT(NVARCHAR (40), @total)), 2),
                    N'Écritures miroir dérivées des flux intragroupe : '
                      + CONVERT(NVARCHAR (40), @total)
                      + N' porté par côté. La contrepartie est le compte de trésorerie pour un reclassement ou une distribution, le compte courant pour une charge.',
                    @qui, SYSUTCDATETIME());

        -- LA QUESTION QUI PORTE L'ECRITURE, exigee par
        -- ck_lot_source_par_famille pour un lot DECIDEE. Le dividende
        -- recu d'une filiale releve du cycle des participations : la
        -- question PART-01, qui porte les parts et actions inscrites
        -- parmi les actifs a caractere immobilier, en est le rattachement
        -- le plus proche. Aucune question du referentiel ne porte
        -- specifiquement la distribution recue d'une filiale, et c'est un
        -- manque du questionnaire, non du script.
        DECLARE @question INT = (SELECT TOP 1 id FROM dbo.ref_question
                                 WHERE reference = 'PART-01');
        INSERT INTO dbo.lot_ecritures
            (arrete, famille, portee, entite, statut, feuille_cote,
             question_id, motif, cree_par, statut_par, statut_le)
        VALUES (@arrete, 'DECIDEE', 'ENTITE', @entite, 'PROPOSE', @cote,
                @question,
                N'Écritures miroir des flux intragroupe, dérivées de dbo.emprunt_intragroupe et du solde de trésorerie. Arbitrage du candidat du 05/09/2026.',
                @qui, @qui, SYSUTCDATETIME());
        SET @lot = CAST(SCOPE_IDENTITY() AS INT);

        -- LES 2 LIGNES ENTRENT EN UN SEUL ORDRE. Le declencheur
        -- tr_lot_equilibre verifie l'equilibre du lot A CHAQUE
        -- insertion, et il a refuse le 05/09/2026 une redaction en 2
        -- ordres : le premier posait le debit seul, et le lot etait
        -- desequilibre le temps d'une instruction. Un lot comptable
        -- n'existe pas a moitie, et le declencheur a raison de
        -- l'imposer.
        INSERT INTO dbo.ecriture
            (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
             compte_num, compte_lib, comp_aux_num, ecriture_lib,
             debit, credit, famille)
        SELECT @lot, 'ODR', N'OD de revision',
               'MIR-' + CAST(p.flux_id AS VARCHAR (10)) + '-'
                 + CAST(x.rang AS VARCHAR (2)),
               (SELECT TOP 1 date_arrete FROM dbo.ref_arrete
                WHERE arrete = @arrete AND entite = @entite),
               CASE WHEN x.rang = 1 THEN p.compte
                    WHEN p.nature = 'DIVIDENDE' THEN p.compte_tresorerie
                    WHEN p.sens = 'DEBIT' THEN '4551'
                    ELSE '266' END,
               N'Contrepartie miroir du flux intragroupe',
               NULL, LEFT(p.lecture, 200),
               -- Le rang 1 porte le sens du flux, le rang 2 l'inverse.
               CASE WHEN x.rang = 1
                    THEN CASE WHEN p.sens = 'DEBIT' THEN p.montant ELSE 0 END
                    ELSE CASE WHEN p.sens = 'DEBIT' THEN 0 ELSE p.montant END
                    END,
               CASE WHEN x.rang = 1
                    THEN CASE WHEN p.sens = 'DEBIT' THEN 0 ELSE p.montant END
                    ELSE CASE WHEN p.sens = 'DEBIT' THEN p.montant ELSE 0 END
                    END,
               'DECIDEE'
        FROM @a_passer p
        CROSS JOIN (SELECT 1 AS rang UNION ALL SELECT 2) AS x
        WHERE p.entite = @entite;

        SET @n = @n + 1;
        FETCH NEXT FROM c INTO @entite;
    END;
    CLOSE c;
    DEALLOCATE c;
    COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'c') >= 0
        BEGIN
            CLOSE c;
            DEALLOCATE c;
        END;
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    -- L'EFFET MESURE, non annonce. Les lots restent au statut PROPOSE : ils
    -- passent par le visa comme tout lot, et l'actif net ne bouge donc
    -- qu'a leur validation.
    SELECT @n AS lots_poses,
           (SELECT COUNT(*) FROM @a_passer) AS ecritures_par_cote,
           N'les lots sont au statut PROPOSE : l''actif net ne bouge qu''à leur validation'
                                            AS lecture;
    SELECT a.entite, a.actif_net AS actif_net_avant,
           v.actif_net_reevalue AS actif_net_apres,
           v.actif_net_reevalue - a.actif_net AS variation
    FROM @avant a
    JOIN dbo.v_anr_entite v ON v.entite = a.entite AND v.arrete = @arrete
    WHERE v.actif_net_reevalue <> a.actif_net
    ORDER BY a.entite;
END;

GO

