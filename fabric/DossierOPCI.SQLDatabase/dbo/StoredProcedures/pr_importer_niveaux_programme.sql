-- ===================================================================== 1. LE REIMPORT DU CLASSEUR DES NIVEAUX DE PROGRAMME
-- ecran 5
-- Objet n° 38 : pose niveau_programme sur les questions de cycle, d'apres les croix Allege, Classique et Etendu du
-- dernier classeur des niveaux (1, 2, 3 ; une ligne sans croix laisse la question a son niveau). Tout ou rien ; chaque
-- refus nomme la ligne du classeur et la question ; n'ecrit que les questions dont le niveau change.
CREATE   PROCEDURE dbo.pr_importer_niveaux_programme
    @lignes  NVARCHAR (MAX)  = NULL,
    @fichier NVARCHAR (4000) = NULL,
    @par     NVARCHAR (400)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- @@TRANCOUNT lu seul, avant toute lecture de table : sous IMPLICIT_TRANSACTIONS (connexion sans autocommit d'une
    -- Data function), la 1re lecture ouvrirait la transaction de l'appelant avant la mesure
    DECLARE @tc INT = @@TRANCOUNT;
    DECLARE @journal_avant INT = ISNULL((SELECT MAX(id) FROM dbo.journal_refus), 0),
            @proc VARCHAR (60) = 'pr_importer_niveaux_programme', @e_num INT, @e_msg NVARCHAR (2048), @e_fr NVARCHAR (2000),
            @e_journal NVARCHAR (2000), @m NVARCHAR (2000), @message NVARCHAR (2000);
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    DECLARE @dernier NVARCHAR (400), @dernier_le DATETIME2 (0), @f NVARCHAR (400), @r INT, @n INT, @x NVARCHAR (1000),
            @modifiees INT, @memes INT, @sans INT, @num INT;
    DECLARE @n_l TABLE (
        rang       INT NOT NULL PRIMARY KEY,
        ligne      INT NULL,
        reference  NVARCHAR (MAX) NULL,
        allege     NVARCHAR (MAX) NULL,
        classique  NVARCHAR (MAX) NULL,
        etendu     NVARCHAR (MAX) NULL,
        a          BIT NULL,
        c          BIT NULL,
        e          BIT NULL,
        question   INT NULL,
        cycle      VARCHAR (10) NULL,
        avant      TINYINT NULL,
        niveau     TINYINT NULL,
        vide       BIT NULL);
    BEGIN TRY
        -- 1. l'auteur, puis par pose avant la 1re ecriture (objet n° 16)
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @par COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50900, N'Action refusée : l’auteur de l’action n’est pas transmis ; l’écran le transmet avec l’adresse de connexion de la personne qui clique.';
        SET @par = LTRIM(RTRIM(@par));
        EXEC sp_set_session_context N'par', @par;
        -- 2. les raisons de [Blocage reimporter les niveaux], dans l'ordre ou la mesure les nomme : aucun classeur depose,
        --    puis reserve a l'associe (mandat ASSOCIE en cours, regle de [Associe du cabinet connecte])
        SELECT TOP (1) @dernier = cc.fichier, @dernier_le = cc.depose_le FROM dbo.classeur_cabinet cc
        WHERE cc.genre = 'NIVEAUX' ORDER BY cc.depose_le DESC, cc.id DESC;
        IF @dernier IS NULL
            EXEC dbo.pr_e5_refuser 50909, N'Réimport refusé : aucun classeur déposé ; « Exporter les niveaux » dépose le classeur des niveaux au dossier Référentiels du site du cabinet.';
        SET @f = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @fichier COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN @dernier ELSE LEFT(LTRIM(RTRIM(@fichier)), 400) END;
        IF @f <> @dernier
        BEGIN
            SET @m = N'Réimport refusé : le classeur relu « ' + @f + N' » n’est pas le dernier classeur des niveaux déposé, « '
                   + @dernier + N' », déposé le ' + CONVERT(NVARCHAR (10), @dernier_le, 103) + N'.';
            EXEC dbo.pr_e5_refuser 50909, @m;
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.role_mission rm WHERE rm.connexion = @par AND rm.role = 'ASSOCIE'
                       AND rm.du <= CAST(SYSUTCDATETIME() AS DATE) AND (rm.au IS NULL OR rm.au > CAST(SYSUTCDATETIME() AS DATE)))
            EXEC dbo.pr_e5_refuser 50908, N'Réimport refusé : réservé à l’associé. Seul l’associé pose les niveaux de programme, et votre adresse de connexion ne porte aucun mandat d’associé en cours.';
        -- 3. le contenu recu : un tableau JSON d'objets
        IF ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM @lignes COLLATE Latin1_General_100_BIN2)), 0) = 0
            EXEC dbo.pr_e5_refuser 50910, N'Réimport refusé : le contenu du classeur des niveaux n’est pas parvenu.';
        IF ISJSON(@lignes) = 0 OR LEFT(LTRIM(@lignes), 1) <> N'['
            EXEC dbo.pr_e5_refuser 50910, N'Réimport refusé : le contenu reçu n’est pas un tableau de lignes lisible.';
        SET @r = NULL;
        SELECT TOP (1) @r = CAST(a.[key] AS INT) + 1 FROM OPENJSON(@lignes) a WHERE a.[type] <> 5 ORDER BY CAST(a.[key] AS INT);
        IF @r IS NOT NULL
        BEGIN
            SET @m = N'Réimport refusé : l’élément ' + CAST(@r AS NVARCHAR (12)) + N' du contenu reçu n’est pas une ligne du classeur.';
            EXEC dbo.pr_e5_refuser 50910, @m;
        END;
        -- chaque cellule lue entiere (NVARCHAR (MAX)) : JSON_VALUE rendrait vide une cellule de plus de 4000 caracteres, et une
        -- colonne de 400 caracteres en leverait l'erreur 2628, en anglais ; la longueur se borne a l'etape 4, ligne nommee
        INSERT INTO @n_l (rang, ligne, reference, allege, classique, etendu)
        SELECT CAST(a.[key] AS INT) + 1, TRY_CAST(j.ligne AS INT), j.reference, j.allege, j.classique, j.etendu
        FROM OPENJSON(@lignes) a
        CROSS APPLY OPENJSON(a.value) WITH (ligne NVARCHAR (MAX) '$."_ligne"', reference NVARCHAR (MAX) '$.reference',
                                            allege NVARCHAR (MAX) '$.allege', classique NVARCHAR (MAX) '$.classique',
                                            etendu NVARCHAR (MAX) '$.etendu') j;
        -- une ligne sans reference ni croix s'ignore (ligne vide de l'onglet)
        UPDATE @n_l SET vide = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM reference COLLATE Latin1_General_100_BIN2)), 0) = 0 AND ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM allege COLLATE Latin1_General_100_BIN2)), 0) = 0 AND ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM classique COLLATE Latin1_General_100_BIN2)), 0) = 0 AND ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM etendu COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN 1 ELSE 0 END;
        DELETE FROM @n_l WHERE vide = 1;
        IF NOT EXISTS (SELECT 1 FROM @n_l)
            EXEC dbo.pr_e5_refuser 50910, N'Réimport refusé : le classeur des niveaux ne porte aucune ligne.';
        -- 4. la question de chaque ligne : une question de cycle, une fois
        UPDATE @n_l SET reference = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM reference COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN NULL ELSE LTRIM(RTRIM(reference)) END;
        -- une cellule de plus de 400 caracteres se refuse, ligne et colonne nommees : la reference (50920), une croix (50921)
        SET @r = NULL;
        SELECT TOP (1) @r = n.rang, @num = CASE WHEN DATALENGTH(n.reference) > 800 THEN 50920 ELSE 50921 END,
               @x = N'la colonne « ' + CASE WHEN DATALENGTH(n.reference) > 800 THEN N'Référence' WHEN DATALENGTH(n.allege) > 800 THEN N'Allégé'
                                            WHEN DATALENGTH(n.classique) > 800 THEN N'Classique' ELSE N'Étendu' END
                  + N' » porte ' + CAST(CASE WHEN DATALENGTH(n.reference) > 800 THEN DATALENGTH(n.reference) WHEN DATALENGTH(n.allege) > 800 THEN DATALENGTH(n.allege)
                                             WHEN DATALENGTH(n.classique) > 800 THEN DATALENGTH(n.classique) ELSE DATALENGTH(n.etendu) END / 2 AS NVARCHAR (12))
                  + N' caractères, pour 400 au plus'
                  + CASE WHEN DATALENGTH(n.reference) > 800 THEN N' ; elle porte la référence d’une question de cycle.' ELSE N' ; mettez X ou laissez vide.' END
        FROM @n_l n
        WHERE DATALENGTH(n.reference) > 800 OR DATALENGTH(n.allege) > 800 OR DATALENGTH(n.classique) > 800 OR DATALENGTH(n.etendu) > 800
        ORDER BY n.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = N'Réimport refusé, ligne ' + CAST(ISNULL(n.ligne, n.rang) AS NVARCHAR (12)) + CASE WHEN n.ligne IS NULL THEN N' reçue' ELSE N' du classeur' END
                      + CASE WHEN n.reference IS NOT NULL AND DATALENGTH(n.reference) <= 800 THEN N' (« ' + n.reference + N' »)' ELSE N'' END
                      + N' : ' + @x + N' Aucune question n’est modifiée.'
            FROM @n_l n WHERE n.rang = @r;
            EXEC dbo.pr_e5_refuser @num, @m;
        END;
        UPDATE n SET question = q.id, cycle = q.cycle, avant = q.niveau_programme
        FROM @n_l n JOIN dbo.ref_question q ON q.reference = n.reference;
        SET @r = NULL;
        SELECT TOP (1) @r = n.rang, @x = CASE WHEN n.reference IS NULL THEN N'la colonne « Référence » est vide ; chaque ligne porte la référence d’une question de cycle.'
                                               WHEN n.question IS NULL THEN N'« ' + LEFT(n.reference, 40) + N' » n’est pas une question de référence.'
                                               ELSE N'la question « ' + n.reference + N' » est une question de phase ; le classeur des niveaux ne porte que les questions de cycle.' END
        FROM @n_l n WHERE n.reference IS NULL OR n.question IS NULL OR n.cycle IS NULL ORDER BY n.rang;
        IF @r IS NULL
            SELECT TOP (1) @r = b.rang, @x = N'la question « ' + b.reference + N' » figure aussi à la ligne ' + CAST(ISNULL(a.ligne, a.rang) AS NVARCHAR (12)) + N' du classeur.'
            FROM @n_l a JOIN @n_l b ON b.rang > a.rang AND b.question = a.question ORDER BY b.rang, a.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = N'Réimport refusé, ligne ' + CAST(ISNULL(n.ligne, n.rang) AS NVARCHAR (12)) + CASE WHEN n.ligne IS NULL THEN N' reçue' ELSE N' du classeur' END
                      + ISNULL(N' (« ' + LEFT(n.reference, 40) + N' »)', N'') + N' : ' + @x + N' Aucune question n’est modifiée.'
            FROM @n_l n WHERE n.rang = @r;
            EXEC dbo.pr_e5_refuser 50920, @m;
        END;
        -- 5. les croix : X ou rien
        UPDATE @n_l SET a = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM allege COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN 0 WHEN UPPER(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM allege COLLATE Latin1_General_100_BIN2)) = N'X' THEN 1 END,
                        c = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM classique COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN 0 WHEN UPPER(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM classique COLLATE Latin1_General_100_BIN2)) = N'X' THEN 1 END,
                        e = CASE WHEN ISNULL(DATALENGTH(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM etendu COLLATE Latin1_General_100_BIN2)), 0) = 0 THEN 0 WHEN UPPER(TRIM(@blancs COLLATE Latin1_General_100_BIN2 FROM etendu COLLATE Latin1_General_100_BIN2)) = N'X' THEN 1 END;
        SET @r = NULL;
        SELECT TOP (1) @r = n.rang, @x = N'la colonne « ' + CASE WHEN n.a IS NULL THEN N'Allégé' WHEN n.c IS NULL THEN N'Classique' ELSE N'Étendu' END
                                       + N' » vaut « ' + LEFT(CASE WHEN n.a IS NULL THEN n.allege WHEN n.c IS NULL THEN n.classique ELSE n.etendu END, 40)
                                       + N' », qui n’est pas une croix ; mettez X ou laissez vide.'
        FROM @n_l n WHERE n.a IS NULL OR n.c IS NULL OR n.e IS NULL ORDER BY n.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = N'Réimport refusé, ligne ' + CAST(ISNULL(n.ligne, n.rang) AS NVARCHAR (12)) + CASE WHEN n.ligne IS NULL THEN N' reçue' ELSE N' du classeur' END
                      + N' (« ' + n.reference + N' ») : ' + @x + N' Aucune question n’est modifiée.'
            FROM @n_l n WHERE n.rang = @r;
            EXEC dbo.pr_e5_refuser 50921, @m;
        END;
        -- 6. les niveaux s'emboitent : une question de l'allege est aussi du classique et de l'etendu, une question du
        --    classique aussi de l'etendu
        SET @r = NULL;
        SELECT TOP (1) @r = n.rang FROM @n_l n WHERE (n.a = 1 AND (n.c = 0 OR n.e = 0)) OR (n.c = 1 AND n.e = 0) ORDER BY n.rang;
        IF @r IS NOT NULL
        BEGIN
            SELECT @m = N'Réimport refusé, ligne ' + CAST(ISNULL(n.ligne, n.rang) AS NVARCHAR (12)) + CASE WHEN n.ligne IS NULL THEN N' reçue' ELSE N' du classeur' END
                      + N' (« ' + n.reference + N' ») : les croix de la question ne s’emboîtent pas ; une question de l’allégé est aussi du classique et de l’étendu, une question du classique aussi de l’étendu. Aucune question n’est modifiée.'
            FROM @n_l n WHERE n.rang = @r;
            EXEC dbo.pr_e5_refuser 50922, @m;
        END;
        UPDATE @n_l SET niveau = CASE WHEN a = 1 THEN 1 WHEN c = 1 THEN 2 WHEN e = 1 THEN 3 END;
        SELECT @modifiees = SUM(CASE WHEN niveau IS NOT NULL AND (avant IS NULL OR avant <> niveau) THEN 1 ELSE 0 END),
               @memes = SUM(CASE WHEN niveau IS NOT NULL AND avant = niveau THEN 1 ELSE 0 END),
               @sans = SUM(CASE WHEN niveau IS NULL THEN 1 ELSE 0 END)
        FROM @n_l;
        IF @modifiees = 0
        BEGIN
            SET @message = N'Aucune modification : le classeur des niveaux « ' + @f + N' » ne change le niveau d’aucune question ('
                         + CAST(@memes AS NVARCHAR (12)) + CASE WHEN @memes > 1 THEN N' questions déjà à leur niveau, ' ELSE N' question déjà à son niveau, ' END
                         + CAST(@sans AS NVARCHAR (12)) + CASE WHEN @sans > 1 THEN N' questions sans croix).' ELSE N' question sans croix).' END;
            EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
            EXEC sp_set_session_context N'par', NULL;
            SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, 0 AS questions_modifiees, @memes AS questions_au_meme_niveau,
                   @sans AS questions_sans_croix;
            RETURN;
        END;
        -- 7. l'ecriture des seules questions dont le niveau change, en une instruction
        BEGIN TRANSACTION;
        UPDATE q SET niveau_programme = n.niveau
        FROM dbo.ref_question q JOIN @n_l n ON n.question = q.id
        WHERE n.niveau IS NOT NULL AND (q.niveau_programme IS NULL OR q.niveau_programme <> n.niveau);
        SET @message = N'Classeur des niveaux « ' + @f + N' » réimporté : '
                     + CAST(@modifiees AS NVARCHAR (12)) + CASE WHEN @modifiees > 1 THEN N' questions changent de niveau, ' ELSE N' question change de niveau, ' END
                     + CAST(@memes AS NVARCHAR (12)) + CASE WHEN @memes > 1 THEN N' questions déjà à leur niveau, ' ELSE N' question déjà à son niveau, ' END
                     + CAST(@sans AS NVARCHAR (12)) + CASE WHEN @sans > 1 THEN N' questions sans croix, laissées à leur niveau.' ELSE N' question sans croix, laissée à son niveau.' END;
        EXEC dbo.pr_poser_message_ecran @pour = @par, @message = @message, @genre = 'SUCCES', @entite = '-', @procedure_nom = @proc;
        COMMIT TRANSACTION;
        EXEC sp_set_session_context N'par', NULL;
        SELECT CAST('-' AS VARCHAR (20)) AS entite, @message AS message, @modifiees AS questions_modifiees, @memes AS questions_au_meme_niveau,
               @sans AS questions_sans_croix;
    END TRY
    BEGIN CATCH
        SELECT @e_num = ERROR_NUMBER(), @e_msg = ERROR_MESSAGE();
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        BEGIN TRY EXEC sp_set_session_context N'par', NULL; END TRY BEGIN CATCH END CATCH;
        -- une contrainte de la table se dit en francais par le libelle de sa colonne, jamais par son nom
        SET @e_fr = dbo.fn_e5_traduire_erreur(@e_num, @e_msg);
        -- un refus de garde (ROLLBACK, inscription, THROW, objet n° 17) recu sous 266 ou 3609 : la ligne qu'un declencheur
        -- a inscrite pour @par depuis l'entree
        IF @e_fr IS NULL AND @e_num IN (266, 3609) AND @par IS NOT NULL
            SELECT TOP (1) @e_fr = j.message FROM dbo.journal_refus j
            WHERE j.id > @journal_avant AND j.procedure_nom LIKE 'tr[_]%' AND j.refuse_pour = LEFT(@par, 200)
            ORDER BY j.id DESC;
        SET @e_journal = ISNULL(@e_fr, @e_msg);
        EXEC dbo.pr_e5_conclure_refus @tc, @journal_avant, @proc, @par, '-', @e_journal;
        IF @e_fr IS NOT NULL EXEC dbo.pr_e5_refuser 50928, @e_fr;
        THROW;
    END CATCH;
END;

GO

