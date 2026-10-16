
-- pr_calculer_annexe : 3 refus
-- ------------------------------------------------------------------------------------------------- le calcul
CREATE   PROCEDURE dbo.pr_calculer_annexe
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20)   = NULL,
    @declencheur VARCHAR (12),
    @par         NVARCHAR (400),
    -- lot B2 : un appelant qui calcule dans sa transaction ne recoit pas la ligne de resultat (@rendre = 0) ; il lit le
    -- nombre de documents perimes et l'identifiant du calcul en sortie
    @rendre            BIT = 1,
    @documents_perimes INT = NULL OUTPUT,
    @calcul_id         INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- les agregats sur des cellules non etablies ignorent les NULL sans avertissement (un message par agregat sinon)
    SET ANSI_WARNINGS OFF;
    -- la transaction de l'appelant, s'il en a une : un refus ou une erreur l'annule avec le calcul ; sans elle, le calcul
    -- annule la sienne avant de relever l'erreur
    DECLARE @tc INT = @@TRANCOUNT;
    BEGIN TRY
    BEGIN TRANSACTION;
    -- le verrou de l'entite, exclusif, propre a la transaction (redemande sans attente par la meme transaction)
    DECLARE @res NVARCHAR (255) = N'annexe:' + CAST(@entite AS NVARCHAR (20)), @rc INT;
    EXEC @rc = sp_getapplock @Resource = @res, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 120000;
    IF @rc < 0
    BEGIN
        DECLARE @mv NVARCHAR (400) = N'L''annexe de l''entité ' + @entite + N' est en cours de calcul : réessayez dans un instant.';
        BEGIN SET @mv = REPLACE(@mv, N'%', N'%%'); THROW 50642, @mv, 1; END
    END;
    IF @arrete IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.v_arrete_etat WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        DECLARE @m40 NVARCHAR (400) = N'Calcul refusé : l''arrêté ' + @arrete + N' de l''entité ' + @entite + N' n''est pas un arrêté de mission ; il n''a pas d''annexe.';
        BEGIN SET @m40 = REPLACE(@m40, N'%', N'%%'); THROW 50640, @m40, 1; END
    END;
    IF @declencheur = 'BOUTON' AND dbo.fn_peut_saisir_annexe(@entite, @par, CAST(SYSUTCDATETIME() AS DATE)) = 0
    BEGIN
        DECLARE @m41 NVARCHAR (400) = N'Calcul refusé : cette personne ne tient aucun rôle de mission sur l''entité ' + @entite + N'.';
        BEGIN SET @m41 = REPLACE(@m41, N'%', N'%%'); THROW 50641, @m41, 1; END
    END;
    DECLARE @debut DATETIME2 (3) = SYSUTCDATETIME();
    INSERT INTO dbo.calcul_annexe (entite, arrete, declencheur, demande_par, debut) VALUES (@entite, @arrete, @declencheur, @par, @debut);
    DECLARE @c INT = SCOPE_IDENTITY();
    -- les marques de l'entite, lues au debut par une lecture ordinaire ; effacees a la fin, elles seules
    DECLARE @marques TABLE (id BIGINT PRIMARY KEY);
    INSERT INTO @marques SELECT id FROM dbo.annexe_retard WHERE entite = @entite;
    -- les cellules de tous les arretes de mission
    EXEC dbo.pr_ann_calculer_travail @c = @c, @entite = @entite;
    DECLARE @maintenant DATETIME2 (3) = SYSUTCDATETIME();
    DECLARE @bilan TABLE (arrete VARCHAR (20), date_arrete DATE, version INT, creee BIT, cellules INT, changees INT, a_remplir INT, en_attente INT, premier BIT);
    DECLARE @a VARCHAR (20), @da DATE, @cree DATETIME2 (7), @der INT, @max INT, @diff INT, @diff_imp INT, @n INT, @ar INT, @at INT;
    DECLARE @perimes INT = 0, @perimes_a INT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT x.arrete, x.date_arrete, r.cree_le FROM dbo.annexe_w_arr x JOIN dbo.ref_arrete r ON r.entite = @entite AND r.arrete = x.arrete
        WHERE x.calcul_id = @c AND x.mission = 1 ORDER BY x.date_arrete, x.arrete;
    OPEN cur; FETCH NEXT FROM cur INTO @a, @da, @cree;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- les cellules calculees, aux colonnes de cellule_annexe
        SELECT w.article, w.ligne, w.colonne, w.libelle, w.ordre, w.groupe, w.signe, CAST(w.valeur AS DECIMAL (19, 6)) AS valeur_numerique,
               CASE WHEN w.etat IN ('LU', 'CALCULE', 'SAISI') AND w.fmt = 'texte' THEN w.texte_valeur END AS valeur_texte,
               w.fmt AS format, w.etat, ISNULL(w.texte, N'') AS texte_affiche, ISNULL(w.texte_imprime, N'') AS texte_imprime, w.obligation, w.nature,
               CAST(CASE WHEN w.etat = 'A_REMPLIR' THEN 1 ELSE 0 END AS BIT) AS comptee, CAST(ISNULL(w.attend_exigee, 0) AS BIT) AS attend_exigee,
               w.attend, w.regle, ISNULL(w.source, N'') AS source, w.formule, w.motif,
               CASE WHEN w.vb_txt IS NOT NULL THEN w.vb_txt WHEN w.vb_num IS NOT NULL THEN dbo.fn_ann_format(w.fmt, w.vb_num) END AS valeur_base,
               w.saisie_ecartee
        INTO #neuf
        FROM dbo.annexe_w_cel w WHERE w.calcul_id = @c AND w.arrete = @a;
        SELECT @n = COUNT(*), @ar = SUM(CAST(comptee AS INT)), @at = SUM(CASE WHEN etat = 'EN_ATTENTE' THEN 1 ELSE 0 END) FROM #neuf;
        SET @der = (SELECT TOP (1) version FROM dbo.annexe_version WHERE entite = @entite AND arrete = @a AND arrete_cree_le = @cree ORDER BY version DESC);
        SET @max = ISNULL((SELECT MAX(version) FROM dbo.annexe_version WHERE entite = @entite AND arrete = @a), 0);
        SELECT @diff = NULL, @diff_imp = NULL;
        IF @der IS NOT NULL
        BEGIN
            SELECT article, ligne, colonne, libelle, ordre, groupe, signe, valeur_numerique, valeur_texte, format, etat, texte_affiche, texte_imprime,
                   obligation, nature, comptee, attend_exigee, attend, regle, source, formule, motif, valeur_base, saisie_ecartee
            INTO #ancien FROM dbo.cellule_annexe WHERE entite = @entite AND arrete = @a AND version = @der;
            -- cellules dont une colonne de contenu differe, ou presentes d'un seul cote
            SELECT @diff = COUNT(*) FROM (
                SELECT article, ligne, colonne FROM (
                    SELECT * FROM #neuf EXCEPT SELECT * FROM #ancien
                    UNION ALL
                    SELECT * FROM (SELECT * FROM #ancien EXCEPT SELECT * FROM #neuf) y) z
                GROUP BY article, ligne, colonne) d;
            -- les memes, sur les champs imprimes (contrat, 2.3)
            SELECT @diff_imp = COUNT(*) FROM (
                SELECT article, ligne, colonne FROM (
                    SELECT article, ligne, colonne, texte_imprime, libelle, ordre, signe, groupe FROM #neuf
                    EXCEPT SELECT article, ligne, colonne, texte_imprime, libelle, ordre, signe, groupe FROM #ancien
                    UNION ALL
                    SELECT * FROM (SELECT article, ligne, colonne, texte_imprime, libelle, ordre, signe, groupe FROM #ancien
                                   EXCEPT SELECT article, ligne, colonne, texte_imprime, libelle, ordre, signe, groupe FROM #neuf) y) z
                GROUP BY article, ligne, colonne) d;
            DROP TABLE #ancien;
        END;
        IF @der IS NULL OR @diff > 0
        BEGIN
            DECLARE @v INT = @max + 1;
            INSERT INTO dbo.annexe_version (entite, arrete, version, arrete_cree_le, calcul_id, cree_le, cree_par, declencheur, cellules, a_remplir,
                                            en_attente, cellules_changees, cellules_imprimees_changees)
            VALUES (@entite, @a, @v, @cree, @c, @maintenant, @par, @declencheur, @n, ISNULL(@ar, 0), ISNULL(@at, 0), @diff, @diff_imp);
            INSERT INTO dbo.cellule_annexe (entite, arrete, version, article, ligne, colonne, libelle, ordre, groupe, signe, valeur_numerique, valeur_texte,
                                            format, etat, texte_affiche, texte_imprime, obligation, nature, comptee, attend_exigee, attend, regle,
                                            source, formule, motif, valeur_base, saisie_ecartee, calcul_id, calcule_le, calcule_par)
            SELECT @entite, @a, @v, article, ligne, colonne, libelle, ordre, groupe, signe, valeur_numerique, valeur_texte, format, etat, texte_affiche,
                   texte_imprime, obligation, nature, comptee, attend_exigee, attend, regle, source, formule, motif, valeur_base, saisie_ecartee,
                   @c, @maintenant, @par
            FROM #neuf;
            INSERT INTO @bilan VALUES (@a, @da, @v, 1, @n, ISNULL(@diff, 0), ISNULL(@ar, 0), ISNULL(@at, 0), CASE WHEN @max = 0 THEN 1 ELSE 0 END);
            SET @der = @v;
            -- les documents de l'arrete qu'une cellule imprimee autrement perime (contrat, 2.3)
            EXEC dbo.pr_ann_perimer_documents @entite = @entite, @arrete = @a, @w = @v, @declencheur = @declencheur, @par = @par,
                 @maintenant = @maintenant, @perimes = @perimes_a OUTPUT;
            SET @perimes += @perimes_a;
        END;
        ELSE
            INSERT INTO @bilan VALUES (@a, @da, @der, 0, @n, 0, ISNULL(@ar, 0), ISNULL(@at, 0), 0);
        -- les controles de l'arrete, remplaces en bloc, sur la derniere version
        DELETE dbo.controle_annexe WHERE entite = @entite AND arrete = @a;
        INSERT INTO dbo.controle_annexe (entite, arrete, controle, cle, article, ecart, effet, version, calcul_id)
        SELECT @entite, @a, k.controle, k.cle, r.article, CAST(k.ecart AS DECIMAL (19, 2)), CASE WHEN r.obstacle = 1 THEN 'obstacle' ELSE 'signal' END, @der, @c
        FROM dbo.annexe_w_ctl k JOIN dbo.ref_controle_annexe r ON r.controle = k.controle
        WHERE k.calcul_id = @c AND k.arrete = @a;
        DROP TABLE #neuf;
        FETCH NEXT FROM cur INTO @a, @da, @cree;
    END;
    CLOSE cur; DEALLOCATE cur;
    -- les marques lues au debut, elles seules
    DELETE dbo.annexe_retard WHERE id IN (SELECT id FROM @marques);
    -- le journal du calcul
    DECLARE @fin DATETIME2 (3) = SYSUTCDATETIME();
    UPDATE dbo.calcul_annexe SET
        fin = @fin,
        arretes = (SELECT STRING_AGG(CAST(arrete AS NVARCHAR (20)), N', ') WITHIN GROUP (ORDER BY date_arrete, arrete) FROM @bilan),
        versions_creees = ISNULL((SELECT STRING_AGG(arrete + N':' + CAST(version AS NVARCHAR (10)), N', ') WITHIN GROUP (ORDER BY date_arrete, arrete) FROM @bilan WHERE creee = 1), N''),
        cellules = ISNULL((SELECT SUM(cellules) FROM @bilan), 0),
        cellules_changees = ISNULL((SELECT SUM(changees) FROM @bilan), 0),
        a_remplir = ISNULL((SELECT SUM(a_remplir) FROM @bilan), 0),
        en_attente = ISNULL((SELECT SUM(en_attente) FROM @bilan), 0),
        documents_perimes = @perimes,
        premier = CASE WHEN EXISTS (SELECT 1 FROM @bilan WHERE premier = 1) THEN 1 ELSE 0 END
    WHERE calcul_id = @c;
    -- les tables de travail du calcul
    DELETE dbo.annexe_w_ops WHERE calcul_id = @c;
    DELETE dbo.annexe_w_cel WHERE calcul_id = @c;
    DELETE dbo.annexe_w_ctl WHERE calcul_id = @c;
    DELETE dbo.annexe_w_arr WHERE calcul_id = @c;
    DELETE dbo.annexe_w_sol WHERE calcul_id = @c;
    DELETE dbo.annexe_w_axe WHERE calcul_id = @c;
    DELETE dbo.annexe_w_etat WHERE calcul_id = @c;
    DELETE dbo.annexe_w_num WHERE calcul_id = @c;
    COMMIT;
    SELECT @documents_perimes = @perimes, @calcul_id = @c;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    IF @rendre = 0 RETURN;
    SELECT k.calcul_id, k.fin AS calcule_le, k.cellules, k.cellules_changees, k.a_remplir, k.en_attente, k.versions_creees, k.documents_perimes,
           k.arretes AS arretes_recalcules,
           N'Annexe recalculée le ' + CONVERT(NVARCHAR (10), k.fin, 103) + N' à ' + LEFT(CONVERT(NVARCHAR (8), k.fin, 108), 5) + N' UTC : '
           + CAST(k.cellules AS NVARCHAR (10)) + N' cellules, dont ' + CAST(k.a_remplir AS NVARCHAR (10)) + N' à remplir et '
           + CAST(k.en_attente AS NVARCHAR (10)) + N' en attente ; versions créées : ' + CASE WHEN k.versions_creees = N'' THEN N'aucune' ELSE k.versions_creees END + N'.' AS message
    FROM dbo.calcul_annexe k WHERE k.calcul_id = @c;
END;

GO

