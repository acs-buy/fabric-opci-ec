
CREATE   PROCEDURE dbo.pr_importer_valeurs
    @vehicule VARCHAR (20),
    @arrete   VARCHAR (20),
    @lignes   NVARCHAR (MAX),
    @par      NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_commun(@vehicule, @arrete, @par);
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    IF ISJSON(ISNULL(@lignes, N'')) <> 1
        THROW 50730, N'Le contenu reçu n''est pas un tableau de lignes lisible.', 1;
    DECLARE @t TABLE (rang INT, ligne INT, actif VARCHAR (20), valeur_expertise DECIMAL (19,2), rapport NVARCHAR (400),
                      valeur_retenue DECIMAL (19,2), source NVARCHAR (60), motif NVARCHAR (600), piece NVARCHAR (400));
    INSERT INTO @t
    SELECT CAST(a.[key] AS INT) + 1, l.ligne, l.actif, l.valeur_expertise, l.rapport, l.valeur_retenue, l.source, l.motif, l.piece
    FROM OPENJSON(@lignes) a
    CROSS APPLY OPENJSON(a.value) WITH (ligne INT '$.ligne', actif VARCHAR (20) '$.actif', valeur_expertise DECIMAL (19,2) '$.valeur_expertise',
                                        rapport NVARCHAR (400) '$.rapport', valeur_retenue DECIMAL (19,2) '$.valeur_retenue',
                                        source NVARCHAR (60) '$.source', motif NVARCHAR (600) '$.motif', piece NVARCHAR (400) '$.piece') l;
    IF NOT EXISTS (SELECT 1 FROM @t)
        THROW 50731, N'Le classeur reçu ne porte aucune ligne.', 1;

    DECLARE @tc INT = @@TRANCOUNT, @i INT, @lg INT, @ac VARCHAR (20), @ve DECIMAL (19,2), @ra NVARCHAR (400), @vr DECIMAL (19,2),
            @so NVARCHAR (60), @mo NVARCHAR (600), @pi NVARCHAR (400), @rid INT, @pid INT, @x NVARCHAR (1000), @cite NVARCHAR (40),
            @resultat VARCHAR (10), @ancienne DECIMAL (19,2), @version INT, @rattachee BIT,
            @inserees INT = 0, @remplacees INT = 0, @inchangees INT = 0, @proposees INT = 0, @refusees INT = 0, @vides INT = 0,
            @detail NVARCHAR (MAX) = N'';
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC dbo.pr_e3_verrouiller @entite = @vehicule;
        DECLARE c CURSOR LOCAL FAST_FORWARD FOR
            SELECT rang, ligne, actif, valeur_expertise, rapport, valeur_retenue, source, motif, piece FROM @t ORDER BY rang;
        OPEN c; FETCH NEXT FROM c INTO @i, @lg, @ac, @ve, @ra, @vr, @so, @mo, @pi;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @cite = N'Ligne ' + CAST(ISNULL(@lg, @i) AS NVARCHAR (10)) + CASE WHEN @lg IS NULL THEN N' reçue' ELSE N' du classeur' END;
            SET @x = NULL;
            IF @ve IS NULL AND @vr IS NULL
                SET @vides += 1;
            ELSE
            BEGIN
                -- l'expertise d'abord : la valeur retenue de la meme ligne peut s'y referer
                IF @ve IS NOT NULL
                BEGIN
                    SET @rid = dbo.fn_e3_piece_par_nom(@vehicule, @arrete, @ra);
                    SET @x = CASE WHEN @rid = -1 THEN N'50709|Le rapport « ' + @ra + N' » est inconnu ou ambigu pour ce véhicule.'
                                  ELSE dbo.fn_e3_refus_expertise(@vehicule, @arrete, @ac, @ve, @rid) END;
                    IF @x IS NULL
                    BEGIN
                        EXEC dbo.pr_e3_ecrire_expertise @arrete, @ac, @ve, @rid, @par, @resultat OUTPUT, @ancienne OUTPUT, @version OUTPUT, @rattachee OUTPUT;
                        IF @resultat = 'INSEREE' SET @inserees += 1;
                        ELSE IF @resultat = 'REMPLACEE' SET @remplacees += 1;
                        ELSE SET @inchangees += 1;
                    END;
                END;
                IF @x IS NULL AND @vr IS NOT NULL
                BEGIN
                    SET @pid = dbo.fn_e3_piece_par_nom(@vehicule, @arrete, @pi);
                    SET @x = CASE WHEN @pid = -1 THEN N'50722|La pièce « ' + @pi + N' » est inconnue ou ambiguë pour ce véhicule.'
                                  ELSE dbo.fn_e3_refus_valeur(@vehicule, @arrete, @ac, @vr, @so, @mo, @pid) END;
                    IF @x IS NULL
                    BEGIN
                        EXEC dbo.pr_e3_ecrire_valeur @arrete, @ac, @vr, @so, @mo, @pid, @par, @resultat OUTPUT;
                        SET @proposees += 1;
                    END;
                END;
                IF @x IS NOT NULL
                BEGIN
                    SET @refusees += 1;
                    SET @detail += CASE WHEN @detail = N'' THEN N'' ELSE N' ' END + @cite + N' : ' + SUBSTRING(@x, 7, 1000);
                END;
            END;
            FETCH NEXT FROM c INTO @i, @lg, @ac, @ve, @ra, @vr, @so, @mo, @pi;
        END;
        CLOSE c; DEALLOCATE c;
        COMMIT;
    END TRY
    BEGIN CATCH
        IF CURSOR_STATUS('local', 'c') >= 0 BEGIN CLOSE c; DEALLOCATE c; END;
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT @vehicule AS vehicule,
           LEFT(N'Classeur réimporté : ' + CAST(@inserees AS NVARCHAR (10)) + N' expertise(s) insérée(s), '
           + CAST(@remplacees AS NVARCHAR (10)) + N' remplacée(s), ' + CAST(@inchangees AS NVARCHAR (10)) + N' inchangée(s) ; '
           + CAST(@proposees AS NVARCHAR (10)) + N' valeur(s) retenue(s) proposée(s) ; '
           + CAST(@refusees AS NVARCHAR (10)) + N' ligne(s) refusée(s).'
           + CASE WHEN @detail <> N'' THEN N' ' + @detail ELSE N'' END, 2000) AS message,
           @inserees AS inserees, @remplacees AS remplacees, @inchangees AS inchangees, @proposees AS proposees,
           @refusees AS refusees, @vides AS vides;
END;

GO

