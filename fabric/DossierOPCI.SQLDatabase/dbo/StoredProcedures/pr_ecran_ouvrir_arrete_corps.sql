-- --- 2. le corps du bouton « Ouvrir l'arrete » fige la periodicite des arretes qu'il planifie ------------------
-- --- 8. le corps du bouton « Ouvrir l'arrete » ---------------------------------------------------------
-- pr_ecran_ouvrir_arrete : le corps d'origine, renomme
-- --- 6. l'etape 6 de la maquette : planifier les arretes de l'exercice, ouvrir le premier ----------
-- 19/11/2026 : un refus des portes garde la planification. Les portes se jugent avant l'ouverture par
-- dbo.fn_portes_arrete ; un refus s'ecrit dans ref_arrete.message_ecran du 1er arrete et dans journal_refus, et la
-- procedure rend ouvert = 0 sans THROW : un THROW condamnerait la transaction de l'enveloppe, planification
-- comprise. Toute autre erreur de l'ouverture leve 50264 et annule tout, comme avant.
-- 19/11/2026 : un seul arrete SEMESTRIEL par exercice (ux_arrete_semestriel, DIP du 1er semestre) ; le retrait
-- d'un arrete passe par pr_arrete_retirer_avec_filiales, dans la boucle (50265, qui nomme l'entite et le travail) et
-- dans le bloc du questionnaire (les arretes des filiales a la date de l'arrete par defaut partent avec lui).
-- Dernier jeu de resultats, 1 ligne : arrete, planifies, ouvert, refus (NULL ou 50025, 50026, 50027), message.
-- (20/11/2026) : la periodicite de la planification se fige sur chaque arrete prevu non ouvert
-- (dbo.arrete_periodicite) ; la periodicite de l'entite ne suit que son dernier exercice planifie ou ouvert.
CREATE   PROCEDURE dbo.pr_ecran_ouvrir_arrete_corps
    @entite          VARCHAR (20),
    @exercice_debut  DATE,
    @exercice_fin    DATE,
    @periodicite_vl  VARCHAR (13),        -- ANNUELLE, SEMESTRIELLE, TRIMESTRIELLE
    @par             NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message NVARCHAR (2000), @premier VARCHAR (20), @planifies INT = 0, @portes NVARCHAR (2000), @refus INT;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
            THROW 50261, N'Un arrêté s''ouvre sur un client du cabinet.', 1;
        IF @periodicite_vl NOT IN ('ANNUELLE', 'SEMESTRIELLE', 'TRIMESTRIELLE')
            THROW 50262, N'La périodicité de la VL est ANNUELLE, SEMESTRIELLE ou TRIMESTRIELLE.', 1;
        IF @exercice_debut >= @exercice_fin OR DATEDIFF(MONTH, @exercice_debut, @exercice_fin) > 23
            THROW 50263, N'L''exercice commence avant sa fin et ne dépasse pas 24 mois.', 1;

        -- les dates d'arrete de l'exercice, a rebours depuis la cloture, selon la periodicite
        DECLARE @pas INT = CASE @periodicite_vl WHEN 'TRIMESTRIELLE' THEN 3 WHEN 'SEMESTRIELLE' THEN 6 ELSE 12 END;
        DECLARE @dates TABLE (d DATE PRIMARY KEY);
        DECLARE @d DATE = @exercice_fin;
        WHILE @d > @exercice_debut
        BEGIN
            INSERT INTO @dates VALUES (@d);
            SET @d = EOMONTH(DATEADD(MONTH, -@pas, @d));
        END;
        DECLARE @ex VARCHAR (20) = CONVERT(VARCHAR (10), @exercice_fin, 23);
        -- la date SEMESTRIEL de l'exercice, une seule (ux_arrete_semestriel, DIP du 1er semestre, DOC-2011-23,
        -- art. 28 I). Un SEMESTRIEL deja ouvert sur l'exercice reste le seul : hors des dates
        -- prevues, aucune date prevue n'est SEMESTRIEL. Sinon la 1re date non finale : les dates sont espacees de 6 mois
        -- depuis la cloture, c'est donc la derniere VL au plus tard a la fin du 1er semestre (art. 28 III), et, a 12 mois
        -- au plus, la seule date non finale, comme avant. Hors SEMESTRIELLE : aucune, comme avant.
        DECLARE @sem DATE = NULL;
        IF @periodicite_vl = 'SEMESTRIELLE'
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND exercice = @ex AND type_arrete = 'SEMESTRIEL')
                SET @sem = (SELECT TOP (1) TRY_CAST(arrete AS DATE) FROM dbo.arrete_mission
                            WHERE entite = @entite AND exercice = @ex AND type_arrete = 'SEMESTRIEL' ORDER BY arrete);
            ELSE
                SET @sem = (SELECT MIN(d) FROM @dates WHERE d < @exercice_fin);
        END;
        -- les arretes que la saisie prevoit, avec le type que pr_planifier_arrete leur donnerait
        DECLARE @prevu TABLE (arrete VARCHAR (20) PRIMARY KEY, type_arrete VARCHAR (14) NOT NULL);
        INSERT INTO @prevu (arrete, type_arrete)
        SELECT CONVERT(VARCHAR (10), d, 23), CASE WHEN d = @exercice_fin THEN 'ANNUEL'
                                                  WHEN d = @sem THEN 'SEMESTRIEL'
                                                  ELSE 'INTERMEDIAIRE' END
        FROM @dates;
        -- les arretes MISSION deja au referentiel que la saisie concerne : ceux de l'exercice vise, et ceux dates dans
        -- l'exercice saisi (]debut, fin])
        DECLARE @concernes TABLE (arrete VARCHAR (20) PRIMARY KEY, exercice VARCHAR (20), type_arrete VARCHAR (14), ouvert BIT);
        INSERT INTO @concernes (arrete, exercice, type_arrete, ouvert)
        SELECT r.arrete, r.exercice, r.type_arrete,
               CASE WHEN EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = r.entite AND am.arrete = r.arrete) THEN 1 ELSE 0 END
        FROM dbo.ref_arrete r
        WHERE r.entite = @entite AND r.nature_technique = 'MISSION'
          AND (r.exercice = @ex OR (r.date_arrete > @exercice_debut AND r.date_arrete <= @exercice_fin));
        -- les autres arretes, non ouverts, d'un ancien exercice d'un arrete concerne, quand
        -- cet exercice n'a aucun arrete ouvert (une fin d'exercice trop longue, corrigee, laisserait sinon sa cloture)
        INSERT INTO @concernes (arrete, exercice, type_arrete, ouvert)
        SELECT r.arrete, r.exercice, r.type_arrete, 0
        FROM dbo.ref_arrete r
        WHERE r.entite = @entite AND r.nature_technique = 'MISSION'
          AND r.exercice IN (SELECT exercice FROM @concernes WHERE exercice <> @ex)
          AND NOT EXISTS (SELECT 1 FROM @concernes c WHERE c.arrete = r.arrete)
          AND NOT EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = r.entite AND am.exercice = r.exercice);
        DECLARE @x VARCHAR (20), @xe VARCHAR (20), @dernier_ouvert VARCHAR (20);

        -- 50266 : un arrete concerne, non ouvert, d'un autre exercice qui a deja un arrete
        -- ouvert ; le retirer ou le realigner demembrerait cet exercice. Avant toute ecriture.
        SELECT TOP (1) @x = c.arrete, @xe = c.exercice FROM @concernes c
        WHERE c.ouvert = 0 AND c.exercice <> @ex
          AND EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = @entite AND am.exercice = c.exercice)
        ORDER BY c.arrete;
        IF @x IS NOT NULL
        BEGIN
            SET @message = N'Planification refusée : l''arrêté du ' + CONVERT(NVARCHAR (10), CAST(@x AS DATE), 103)
                         + N' appartient à l''exercice clos le ' + ISNULL(CONVERT(NVARCHAR (10), TRY_CAST(@xe AS DATE), 103), @xe)
                         + N', qui a déjà un arrêté ouvert. Reprenez le début et la fin de cet exercice.';
            SET @message = REPLACE(@message, N'%', N'%%');
            THROW 50266, @message, 1;
        END;
        SET @x = NULL;

        -- 50266 : un arrete deja ouvert, date dans l'exercice saisi, rattache a un autre exercice. Avant toute ecriture.
        SELECT TOP (1) @x = arrete, @xe = exercice FROM @concernes WHERE ouvert = 1 AND exercice <> @ex ORDER BY arrete;
        IF @x IS NOT NULL
        BEGIN
            SET @message = N'Planification refusée : l''arrêté du ' + CONVERT(NVARCHAR (10), CAST(@x AS DATE), 103)
                         + N' est déjà ouvert sur l''exercice clos le ' + ISNULL(CONVERT(NVARCHAR (10), TRY_CAST(@xe AS DATE), 103), @xe)
                         + N'. Reprenez le début et la fin de cet exercice.';
            SET @message = REPLACE(@message, N'%', N'%%');
            THROW 50266, @message, 1;
        END;
        -- 50267 : un arrete prevu, non ouvert, anterieur au dernier arrete ouvert de l'exercice ; il s'ouvrirait
        -- apres un arrete posterieur. Avant toute ecriture.
        SET @dernier_ouvert = (SELECT MAX(arrete) FROM @concernes WHERE ouvert = 1);
        SET @x = (SELECT MIN(p.arrete) FROM @prevu p WHERE p.arrete < @dernier_ouvert
                  AND NOT EXISTS (SELECT 1 FROM @concernes c WHERE c.arrete = p.arrete AND c.ouvert = 1));
        IF @x IS NOT NULL
        BEGIN
            SET @message = N'Planification refusée : l''arrêté du ' + CONVERT(NVARCHAR (10), CAST(@x AS DATE), 103)
                         + N' précéderait celui du ' + CONVERT(NVARCHAR (10), CAST(@dernier_ouvert AS DATE), 103)
                         + N', déjà ouvert. Reprenez la périodicité de la VL de la planification.';
            SET @message = REPLACE(@message, N'%', N'%%');
            THROW 50267, @message, 1;
        END;

        BEGIN TRANSACTION;
        -- la periodicite de l'entite se met a jour avant le COMMIT, une fois les
        -- retraits, realignements et planifications faits.

        -- une planification gardee apres un refus se corrige au clic suivant. Un arrete concerne, non ouvert, que
        -- la saisie ne prevoit pas est retire avec les arretes de ses filiales a sa date, s'il ne porte aucun travail ;
        -- sinon 50265, tout annule. Le retrait passe par pr_arrete_retirer_avec_filiales ; le 50265 nomme l'entite et le travail.
        DECLARE @ret BIT, @porteur VARCHAR (20), @trouve NVARCHAR (128), @r CURSOR;
        SET @r = CURSOR FAST_FORWARD FOR
            SELECT c.arrete FROM @concernes c WHERE c.ouvert = 0 AND NOT EXISTS (SELECT 1 FROM @prevu p WHERE p.arrete = c.arrete)
              -- l'arrete de l'acceptation (feuille ACC, visa ACCEPTATION) n'est jamais retire ici ;
              -- le bloc du questionnaire, plus bas, en decide
              AND c.arrete NOT IN (SELECT ft.arrete FROM dbo.feuille_travail ft WHERE ft.cote = 'ACC-' + @entite)
              AND NOT EXISTS (SELECT 1 FROM dbo.visa v WHERE v.nature = 'ACCEPTATION' AND v.entite = @entite AND v.arrete = c.arrete)
            ORDER BY c.arrete;
        OPEN @r; FETCH NEXT FROM @r INTO @x;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.pr_arrete_retirer_avec_filiales @entite, @x, @ret OUTPUT, @porteur OUTPUT, @trouve OUTPUT;
            IF @ret = 0
            BEGIN
                SET @message = N'Planification refusée : l''arrêté du ' + CONVERT(NVARCHAR (10), CAST(@x AS DATE), 103)
                             + N' est déjà planifié et porte des travaux, et la saisie ne le prévoit pas. Travail trouvé sur '
                             + ISNULL(@porteur, @entite) + ISNULL(N' : ' + @trouve, N'') + N'. Reprenez le début '
                             + N'd''exercice, la fin d''exercice et la périodicité de la VL de la planification.';
                SET @message = REPLACE(@message, N'%', N'%%');
                THROW 50265, @message, 1;
            END;
            FETCH NEXT FROM @r INTO @x;
        END;
        CLOSE @r; DEALLOCATE @r;
        -- un arrete concerne, non ouvert, que la saisie prevoit sous un autre exercice ou un autre type est realigne
        -- sur place ; ses pieces, feuilles et ecritures le suivent.
        UPDATE r
           SET exercice = @ex, date_cloture = @exercice_fin, type_arrete = p.type_arrete,
               rang_exercice = 1 + ISNULL((SELECT COUNT(DISTINCT z.exercice) FROM dbo.ref_arrete z
                                           WHERE z.entite = @entite AND z.nature_technique = 'MISSION' AND z.exercice < @ex), 0)
          FROM dbo.ref_arrete r
          JOIN @concernes c ON c.arrete = r.arrete AND c.ouvert = 0
          JOIN @prevu p ON p.arrete = r.arrete
         WHERE r.entite = @entite AND (r.exercice <> @ex OR r.type_arrete <> p.type_arrete);

        DECLARE @c CURSOR, @type VARCHAR (14), @a VARCHAR (20);
        SET @c = CURSOR FAST_FORWARD FOR SELECT d FROM @dates ORDER BY d;
        OPEN @c; FETCH NEXT FROM @c INTO @d;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @a = CONVERT(VARCHAR (10), @d, 23);
            IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @a)
            BEGIN
                SET @type = (SELECT type_arrete FROM @prevu WHERE arrete = @a);
                EXEC dbo.pr_planifier_arrete @entite, @d, @exercice_fin, @type, @par, @calculer = 0;
                SET @planifies += 1;
            END
            ELSE
                -- une date deja planifiee recoit les arretes des filiales qui lui manquent (une filiale ajoutee
                -- apres la planification n'en a pas : pr_ajouter_filiale ne planifie rien).
                EXEC dbo.pr_planifier_arretes_filiales @entite, @a, @par, @calculer = 0;
            FETCH NEXT FROM @c INTO @d;
        END;
        CLOSE @c; DEALLOCATE @c;
        -- le rang de l'exercice, relu apres retraits, realignements et planification
        UPDATE dbo.ref_arrete
           SET rang_exercice = 1 + ISNULL((SELECT COUNT(DISTINCT z.exercice) FROM dbo.ref_arrete z
                                           WHERE z.entite = @entite AND z.nature_technique = 'MISSION' AND z.exercice < @ex), 0)
         WHERE entite = @entite AND nature_technique = 'MISSION' AND exercice = @ex
           AND rang_exercice <> 1 + ISNULL((SELECT COUNT(DISTINCT z.exercice) FROM dbo.ref_arrete z
                                            WHERE z.entite = @entite AND z.nature_technique = 'MISSION' AND z.exercice < @ex), 0);
        -- : chaque arrete prevu et non ouvert recoit la periodicite de cette planification, qui a fixe son type ;
        -- un arrete ouvert garde la sienne.
        UPDATE ap SET periodicite_vl = @periodicite_vl, fixee_le = SYSUTCDATETIME(), fixee_par = LEFT(@par, 400)
          FROM dbo.arrete_periodicite ap JOIN @prevu p ON p.arrete = ap.arrete
         WHERE ap.entite = @entite AND ap.periodicite_vl <> @periodicite_vl
           AND NOT EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = @entite AND am.arrete = ap.arrete);
        INSERT INTO dbo.arrete_periodicite (entite, arrete, periodicite_vl, fixee_par)
        SELECT @entite, p.arrete, @periodicite_vl, LEFT(@par, 400) FROM @prevu p
         WHERE EXISTS (SELECT 1 FROM dbo.ref_arrete r WHERE r.entite = @entite AND r.arrete = p.arrete)
           AND NOT EXISTS (SELECT 1 FROM dbo.arrete_periodicite ap WHERE ap.entite = @entite AND ap.arrete = p.arrete)
           AND NOT EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = @entite AND am.arrete = p.arrete);
        -- le 1er arrete a ouvrir est la 1re date prevue non ouverte ; toutes ouvertes, la 1re
        -- (deja ouverte : reussite sans ecriture, comme avant).
        SET @premier = ISNULL((SELECT MIN(p.arrete) FROM @prevu p
                               WHERE NOT EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = @entite AND am.arrete = p.arrete)),
                              (SELECT MIN(arrete) FROM @prevu));

        -- le questionnaire d'acceptation s'etait adosse a la cloture par defaut : s'il vise un
        -- arrete hors de cet exercice, il se re-adosse a la cloture retenue, et la ligne planifiee
        -- par defaut est retiree si plus rien ne la reference.
        -- seulement tant qu'aucun arrete du client n'est ouvert. Ensuite, le questionnaire appartient au 1er
        -- exercice de la mission et ne suit pas la planification des exercices suivants.
        DECLARE @cote VARCHAR (30) = 'ACC-' + @entite, @ancien VARCHAR (20);
        SELECT @ancien = arrete FROM dbo.feuille_travail WHERE cote = @cote;
        IF @ancien IS NOT NULL AND @ancien NOT IN (SELECT CONVERT(VARCHAR (10), d, 23) FROM @dates)
           AND NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite)
        BEGIN
            UPDATE dbo.feuille_travail SET arrete = CONVERT(VARCHAR (10), @exercice_fin, 23) WHERE cote = @cote;
            -- l'arrete par defaut n'est retire que s'il ne porte plus aucun travail, juge sur
            -- toutes les cles ; un visa d'acceptation ou une piece permanente le garde, sans l'erreur 547 d'avant.
            -- : avec les arretes de ses filiales a sa date, par pr_arrete_retirer_avec_filiales ; un travail sur
            -- l'un d'eux les garde tous, sans refus.
            IF EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @ancien AND est_arrete_client = 1)
               AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND exercice = @ancien AND arrete <> @ancien)
                EXEC dbo.pr_arrete_retirer_avec_filiales @entite, @ancien, @ret OUTPUT, @porteur OUTPUT, @trouve OUTPUT;
        END;
        -- la periodicite de l'entite est celle de son dernier
        -- exercice planifie par ce bouton ou ouvert ; planifier un exercice anterieur ne la reecrit plus. L'arrete par
        -- defaut du questionnaire, ni planifie ici ni ouvert, ne compte pas. Juge apres les retraits du meme clic.
        UPDATE dbo.ref_entite SET periodicite_vl = @periodicite_vl WHERE code = @entite
           AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete z WHERE z.entite = @entite AND z.nature_technique = 'MISSION' AND z.exercice > @ex
                             AND (EXISTS (SELECT 1 FROM dbo.arrete_periodicite x WHERE x.entite = z.entite AND x.arrete = z.arrete)
                                  OR EXISTS (SELECT 1 FROM dbo.arrete_mission am WHERE am.entite = z.entite AND am.arrete = z.arrete)));
        -- : la ligne d'un arrete de l'entite qui n'est plus au referentiel (retire ici ou ailleurs) part. La table
        -- n'a pas de cle etrangere : pr_arrete_porte_travail, v_arrete_travail et v_entite_donnees, qui lisent le
        -- catalogue, y verraient un travail.
        DELETE ap FROM dbo.arrete_periodicite ap
         WHERE ap.entite = @entite
           AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete r WHERE r.entite = ap.entite AND r.arrete = ap.arrete);
        COMMIT;

        -- les portes se jugent avant l'ouverture ; un refus garde la planification et s'ecrit sur l'arrete
        IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @premier)
        BEGIN
            SET @portes = dbo.fn_portes_arrete(@entite, @premier);
            IF @portes IS NOT NULL
            BEGIN
                SET @refus = CAST(LEFT(@portes, 5) AS INT);
                SET @message = N'L''arrêté du ' + CONVERT(NVARCHAR (10), CAST(@premier AS DATE), 103) + N' ne s''ouvre pas. '
                             + LEFT(SUBSTRING(@portes, 7, 2000), 1700);
                BEGIN TRANSACTION;
                UPDATE dbo.ref_arrete
                   SET message_ecran = @message, message_ecran_le = SYSUTCDATETIME(), message_ecran_pour = LEFT(@par, 200)
                 WHERE entite = @entite AND arrete = @premier;
                INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, refuse_pour)
                VALUES ('pr_ecran_ouvrir_arrete', @entite, @premier, @message, LEFT(@par, 200));
                COMMIT;
                SELECT @premier AS arrete, @planifies AS planifies, CAST(0 AS BIT) AS ouvert, @refus AS refus,
                       @message AS message;
                RETURN;
            END;
        END;

        -- ouvrir le premier arrete ; une erreur autre que les portes leve 50264, qui le nomme, et annule tout
        BEGIN TRY
            IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @premier)
            BEGIN
                DECLARE @tp VARCHAR (14) = (SELECT type_arrete FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @premier);
                EXEC dbo.pr_ouvrir_arrete @entite, @premier, @tp, @par, @ex, NULL;
            END;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
            SET @message = N'L''arrêté du ' + CONVERT(NVARCHAR (10), CAST(@premier AS DATE), 103) + N' ne s''ouvre pas. '
                         + LEFT(ERROR_MESSAGE(), 1700);
            SET @message = REPLACE(@message, N'%', N'%%');
            THROW 50264, @message, 1;
        END CATCH;

        -- le compte de l'exercice, et non celui du clic, qui vaut 0 apres un 1er refus
        -- pluriel calcule, jamais « (s) » dans un texte affiche
        DECLARE @nb INT = (SELECT COUNT(*) FROM dbo.ref_arrete WHERE entite = @entite AND exercice = @ex AND nature_technique = 'MISSION');
        SET @message = N'Arrêté du ' + CONVERT(NVARCHAR (10), CAST(@premier AS DATE), 103) + N' ouvert : la révision peut commencer. '
                     + CAST(@nb AS NVARCHAR (10)) + CASE WHEN @nb > 1 THEN N' arrêtés planifiés' ELSE N' arrêté planifié' END
                     + N' sur l''exercice, périodicité ' + LOWER(@periodicite_vl) + N'.';
        UPDATE dbo.ref_arrete SET message_ecran = NULL, message_ecran_le = NULL, message_ecran_pour = NULL
         WHERE entite = @entite AND arrete = @premier;
        SELECT @premier AS arrete, @planifies AS planifies, CAST(1 AS BIT) AS ouvert, CAST(NULL AS INT) AS refus,
               @message AS message;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

