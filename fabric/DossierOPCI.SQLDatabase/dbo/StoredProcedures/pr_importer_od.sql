

-- LE CLASSEUR D'OD D'UNE QUESTION, OU DES OD LIBRES : ses lignes REMPLACENT le brouillon courant du meme
-- perimetre. @lignes : [{"ligne":12,"journal":"ODR","compte":"213","libelle":"...","debit":100,"credit":0,"piece":"...","actif":"IMM-201"}]
-- « ligne » est le numero de la ligne dans l'onglet, que la fonction releve avant d'ecarter une ligne.
-- Toutes les lignes sont controlees avant toute ecriture : un refus n'ecrit rien, et dit la ligne.
-- POUR LES OD LIBRES, @fichier est obligatoire, et le classeur ne peut ni faire perdre une ligne
-- saisie depuis son instant de reference R, ni faire revenir une ligne retiree depuis R. R est le plus
-- tardif du dernier depot FAIT du classeur et de son dernier reimport accepte.
CREATE   PROCEDURE dbo.pr_importer_od
    @entite     VARCHAR (20),
    @arrete     VARCHAR (20),
    @reference  VARCHAR (20)   = NULL,
    @lignes     NVARCHAR (MAX),
    @par        NVARCHAR (400),
    @fichier    NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF ISJSON(@lignes) <> 1
        THROW 50385, N'Le contenu reçu n''est pas un tableau de lignes lisible.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé.', 1;
    SET @fichier = NULLIF(LTRIM(RTRIM(@fichier)), N'');
    IF @reference IS NULL AND @fichier IS NULL
        THROW 50409, N'Réimport refusé : le nom du classeur relu manque ; il établit la date de son export.', 1;

    DECLARE @t TABLE (rang INT, ligne INT, journal VARCHAR (10), compte VARCHAR (20), libelle NVARCHAR (400),
                      debit DECIMAL (19, 2), credit DECIMAL (19, 2), piece VARCHAR (50), actif VARCHAR (20));
    INSERT INTO @t (rang, ligne, journal, compte, libelle, debit, credit, piece, actif)
    SELECT CAST(a.[key] AS INT) + 1, l.ligne, l.journal, l.compte, l.libelle, ISNULL(l.debit, 0), ISNULL(l.credit, 0), l.piece, l.actif
    FROM OPENJSON(@lignes) a
    CROSS APPLY OPENJSON(a.value) WITH (ligne INT '$.ligne', journal VARCHAR (10) '$.journal', compte VARCHAR (20) '$.compte',
                                        libelle NVARCHAR (400) '$.libelle', debit DECIMAL (19, 2) '$.debit', credit DECIMAL (19, 2) '$.credit',
                                        piece VARCHAR (50) '$.piece', actif VARCHAR (20) '$.actif') l
    WHERE l.compte IS NOT NULL;
    DECLARE @n INT = (SELECT COUNT(*) FROM @t);
    DECLARE @i INT, @lg INT, @j VARCHAR (10), @co VARCHAR (20), @li NVARCHAR (400), @d DECIMAL (19, 2), @cr DECIMAL (19, 2),
            @pi VARCHAR (50), @ac VARCHAR (20), @qid INT, @cote VARCHAR (30), @fqid INT, @num INT, @m NVARCHAR (2000);

    -- 0. la question, pour un classeur d'OD liees, meme sans ligne
    IF @reference IS NOT NULL
    BEGIN
        SELECT @qid = q.id, @cote = fq.cote, @fqid = fq.id FROM dbo.ref_question q
        JOIN dbo.feuille_question fq ON fq.question_id = q.id
        JOIN dbo.feuille_travail f ON f.cote = fq.cote AND f.entite = @entite AND f.arrete = @arrete AND f.cote LIKE 'Q-%'
        WHERE q.reference = @reference;
        IF @qid IS NULL
        BEGIN
            SET @m = N'La question ' + @reference + N' n''est pas au programme de cet arrêté.';
            THROW 50384, @m, 1;
        END;
    END;

    -- 1. chaque ligne, controlee avant toute ecriture
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT rang, ligne, journal, compte, debit, credit FROM @t ORDER BY rang;
    OPEN c; FETCH NEXT FROM c INTO @i, @lg, @j, @co, @d, @cr;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            EXEC dbo.pr_controler_ligne_od @entite, @arrete, @co, @d, @cr, @reference, @j, @qid OUTPUT, @cote OUTPUT, @fqid OUTPUT;
        END TRY
        BEGIN CATCH
            SELECT @num = ERROR_NUMBER(),
                   @m = LEFT(CASE WHEN @lg IS NOT NULL THEN N'Ligne ' + CAST(@lg AS NVARCHAR (10)) + N' du classeur : '
                                  ELSE N'Ligne ' + CAST(@i AS NVARCHAR (10)) + N' reçue : ' END + dbo.fn_sans_entete_ligne(ERROR_MESSAGE()), 2000);
            IF @num < 50000 THROW;
            THROW @num, @m, 1;
        END CATCH;
        FETCH NEXT FROM c INTO @i, @lg, @j, @co, @d, @cr;
    END;
    CLOSE c; DEALLOCATE c;
    IF @reference IS NULL
        EXEC dbo.pr_assurer_feuille_od_libres @entite, @arrete, @par, @cote OUTPUT;

    -- 2. OD libres : la garde de l'instant de reference
    IF @reference IS NULL
    BEGIN
        DECLARE @R DATETIME2 (3) = (SELECT MAX(x) FROM (
            SELECT MAX(depose_le) AS x FROM dbo.export_dossier WHERE entite = @entite AND arrete = @arrete AND fichier = @fichier AND statut = 'FAIT'
            UNION ALL
            SELECT MAX(le) FROM dbo.od_reimport WHERE entite = @entite AND arrete = @arrete AND fichier = @fichier) r);
        IF @R IS NULL
        BEGIN
            SET @m = N'Réimport refusé : le classeur « ' + @fichier + N' » n''a ni dépôt ni réimport connu pour cet arrêté ; la date de son export n''est pas établie.';
            THROW 50406, @m, 1;
        END;
        -- la cle d'une ligne : compte, libelle sans espaces de bord, debit, credit, piece, actif
        DECLARE @cl TABLE (cle NVARCHAR (500));
        INSERT INTO @cl SELECT ISNULL(compte, '') + N'|' + LTRIM(RTRIM(ISNULL(libelle, N''))) + N'|' + CAST(debit AS NVARCHAR (30)) + N'|'
                             + CAST(credit AS NVARCHAR (30)) + N'|' + ISNULL(piece, '') + N'|' + ISNULL(actif, '') FROM @t;
        DECLARE @br TABLE (id INT, cle NVARCHAR (500), compte VARCHAR (20), libelle NVARCHAR (200), debit DECIMAL (19, 2), credit DECIMAL (19, 2),
                           saisi_par NVARCHAR (200), saisi_le DATETIME2 (3));
        INSERT INTO @br SELECT id, compte_num + N'|' + LTRIM(RTRIM(libelle)) + N'|' + CAST(debit AS NVARCHAR (30)) + N'|' + CAST(credit AS NVARCHAR (30))
                             + N'|' + ISNULL(reference, '') + N'|' + ISNULL(code_actif, ''), compte_num, libelle, debit, credit, saisi_par, saisi_le
        FROM dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL;
        DECLARE @heure NVARCHAR (40) = FORMAT(CAST((@R AT TIME ZONE 'UTC') AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (0)), 'dd/MM/yyyy') + N' à '
                                     + FORMAT(CAST((@R AT TIME ZONE 'UTC') AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (0)), 'HH:mm');
        -- 2a. une saisie depuis R ne se perd pas
        DECLARE @perdues TABLE (compte VARCHAR (20), libelle NVARCHAR (200), debit DECIMAL (19, 2), credit DECIMAL (19, 2), saisi_par NVARCHAR (200), saisi_le DATETIME2 (3));
        INSERT INTO @perdues
        SELECT b.compte, b.libelle, b.debit, b.credit, b.saisi_par, b.saisi_le FROM @br b
        WHERE b.saisi_le > @R
          AND (SELECT COUNT(*) FROM @cl c WHERE c.cle = b.cle) < (SELECT COUNT(*) FROM @br x WHERE x.cle = b.cle);
        IF EXISTS (SELECT 1 FROM @perdues)
        BEGIN
            SET @m = LEFT(N'Réimport refusé : ' + CAST((SELECT COUNT(*) FROM @perdues) AS NVARCHAR (10)) + N' ligne(s) écrite(s) depuis l''export ou le dernier réimport de ce classeur, le '
                   + @heure + N', à l''écran ou par un autre classeur, n''y figurent pas : '
                   + (SELECT STRING_AGG(CAST(compte + ' ' + libelle + ' ' + FORMAT(debit, 'N2', 'fr-FR') + ' / ' + FORMAT(credit, 'N2', 'fr-FR') + ', '
                                             + saisi_par + ' ' + FORMAT(CAST((saisi_le AT TIME ZONE 'UTC') AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (0)), 'dd/MM HH:mm') AS NVARCHAR (MAX)), N' ; ')
                      FROM @perdues)
                   + N'. Les reporter dans le classeur, ou les retirer à l''écran, puis réimporter.', 2000);
            THROW 50405, @m, 1;
        END;
        -- 2b. un retrait depuis R ne revient pas
        DECLARE @revenues TABLE (compte VARCHAR (20), libelle NVARCHAR (200), debit DECIMAL (19, 2), credit DECIMAL (19, 2), retire_par NVARCHAR (400), retire_le DATETIME2 (3));
        INSERT INTO @revenues
        SELECT r.compte_num, r.libelle, r.debit, r.credit, r.retire_par, r.retire_le
        FROM dbo.od_retrait r
        CROSS APPLY (SELECT r.compte_num + N'|' + LTRIM(RTRIM(r.libelle)) + N'|' + CAST(r.debit AS NVARCHAR (30)) + N'|' + CAST(r.credit AS NVARCHAR (30))
                            + N'|' + ISNULL(r.piece_ref, '') + N'|' + ISNULL(r.code_actif, '') AS cle) k
        WHERE r.entite = @entite AND r.arrete = @arrete AND r.feuille_cote = @cote AND r.retire_le > @R AND r.saisi_le <= @R
          AND (SELECT COUNT(*) FROM @cl c WHERE c.cle = k.cle) > (SELECT COUNT(*) FROM @br x WHERE x.cle = k.cle);
        IF EXISTS (SELECT 1 FROM @revenues)
        BEGIN
            SET @m = LEFT(N'Réimport refusé : ' + CAST((SELECT COUNT(*) FROM @revenues) AS NVARCHAR (10)) + N' ligne(s) retirée(s) depuis l''export ou le dernier réimport de ce classeur, à l''écran ou par un autre classeur, y figurent encore : '
                   + (SELECT STRING_AGG(CAST(compte + ' ' + libelle + ' ' + FORMAT(debit, 'N2', 'fr-FR') + ' / ' + FORMAT(credit, 'N2', 'fr-FR') + ', '
                                             + retire_par + ' ' + FORMAT(CAST((retire_le AT TIME ZONE 'UTC') AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (0)), 'dd/MM HH:mm') AS NVARCHAR (MAX)), N' ; ')
                      FROM @revenues)
                   + N'. Les supprimer du classeur, puis réimporter.', 2000);
            THROW 50408, @m, 1;
        END;
    END;

    -- 3. l'ecriture, tout ou rien
    DECLARE @t1 DATETIME2 (3) = SYSUTCDATETIME();
    BEGIN TRY
    BEGIN TRANSACTION;
    IF @reference IS NULL
        INSERT INTO dbo.od_retrait (entite, arrete, feuille_cote, brouillon_id, compte_num, libelle, debit, credit, piece_ref, code_actif,
                                    saisi_par, saisi_le, motif, retire_par, retire_le)
        SELECT entite, arrete, feuille_cote, id, compte_num, libelle, debit, credit, reference, code_actif, saisi_par, saisi_le,
               LEFT(N'réimport du classeur ' + @fichier, 400), @par, @t1
        FROM dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL;
    DELETE dbo.ecriture_brouillon WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote
       AND ((@qid IS NULL AND question_id IS NULL) OR question_id = @qid);
    INSERT INTO dbo.ecriture_brouillon (entite, arrete, feuille_cote, journal_code, compte_num, libelle, debit, credit, saisi_par,
                                        question_id, reference, code_actif, feuille_question_id)
    SELECT @entite, @arrete, @cote, 'ODR', compte, libelle, debit, credit, @par, @qid, piece, actif, @fqid FROM @t ORDER BY rang;
    IF @reference IS NULL
    BEGIN
        DECLARE @t2 DATETIME2 (3) = SYSUTCDATETIME();
        DECLARE @dernier DATETIME2 (3) = (SELECT MAX(saisi_le) FROM dbo.ecriture_brouillon
                                          WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND question_id IS NULL);
        IF @dernier IS NOT NULL AND @dernier > @t2 SET @t2 = @dernier;
        IF @t2 <= @t1 SET @t2 = DATEADD(MILLISECOND, 1, @t1);
        INSERT INTO dbo.od_reimport (entite, arrete, fichier, lignes, par, le) VALUES (@entite, @arrete, @fichier, @n, @par, @t2);
    END;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    DECLARE @sd DECIMAL (19, 2), @sc DECIMAL (19, 2);
    SELECT @sd = ISNULL(SUM(debit), 0), @sc = ISNULL(SUM(credit), 0) FROM dbo.ecriture_brouillon
     WHERE entite = @entite AND arrete = @arrete AND feuille_cote = @cote AND ((@qid IS NULL AND question_id IS NULL) OR question_id = @qid);
    SELECT @cote AS cote, @n AS lignes, @sd AS debit, @sc AS credit,
           CAST(@n AS NVARCHAR (10)) + N' ligne(s) d''OD au brouillon' + CASE WHEN @reference IS NOT NULL THEN N' de la question ' + @reference ELSE N' libres' END
         + CASE WHEN @sd <> @sc THEN N'. Déséquilibre de ' + FORMAT(@sd - @sc, 'N2', 'fr-FR') + N' : la validation le refusera.' ELSE N', équilibrées.' END AS message;
END;

GO

