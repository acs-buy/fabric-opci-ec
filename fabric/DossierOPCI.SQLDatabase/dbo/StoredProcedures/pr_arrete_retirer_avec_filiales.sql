-- --- 5. retirer un arrete et ceux de ses filiales a sa date ----------------------------------------
-- l'arrete @arrete de @entite, et les arretes HORS_MISSION de ses filiales declarees a la meme date qu'aucun autre
-- vehicule ne tient a cette date, sont retires ensemble si aucun ne porte de travail (pr_arrete_porte_travail) ; sinon
-- rien n'est retire, @retire = 0, et @porteur, @trouve nomment le 1er travail trouve. Ni transaction ni THROW : la
-- procedure appelante decide (50265 dans la boucle de retrait, silence dans le bloc du questionnaire).
CREATE   PROCEDURE dbo.pr_arrete_retirer_avec_filiales
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @retire  BIT OUTPUT,
    @porteur VARCHAR (20) OUTPUT,
    @trouve  NVARCHAR (128) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @t BIT, @f VARCHAR (20), @k CURSOR;
    DECLARE @fil TABLE (entite VARCHAR (20) PRIMARY KEY);
    SELECT @retire = 0, @porteur = NULL, @trouve = NULL;
    EXEC dbo.pr_arrete_porte_travail @entite, @arrete, @t OUTPUT, @trouve OUTPUT;
    IF @t = 1
    BEGIN
        SET @porteur = @entite;
        -- une expertise nomme le detenteur de l'actif, le vehicule d'abord, sinon sa filiale
        IF @trouve = N'expertise'
            SET @porteur = ISNULL((SELECT TOP (1) a.entite_detentrice FROM dbo.expertise x JOIN dbo.actif a ON a.code = x.code_actif
                                   WHERE x.date_valeur = TRY_CAST(@arrete AS DATE)
                                     AND (a.entite_detentrice = @entite
                                          OR a.entite_detentrice IN (SELECT f.entite_fille FROM dbo.fn_filiales_a_l_arrete(@entite, @arrete) f))
                                   ORDER BY CASE WHEN a.entite_detentrice = @entite THEN 0 ELSE 1 END, a.entite_detentrice), @entite);
        RETURN;
    END;
    INSERT INTO @fil (entite)
    SELECT DISTINCT ra.entite FROM dbo.ref_arrete ra
    JOIN dbo.eligibilite_participation ep ON ep.entite_mere = @entite AND ep.entite_fille = ra.entite
    WHERE ra.arrete = @arrete AND ra.nature_technique = 'HORS_MISSION'
      AND NOT EXISTS (SELECT 1 FROM dbo.eligibilite_participation ep2
                      JOIN dbo.ref_arrete r2 ON r2.entite = ep2.entite_mere AND r2.arrete = @arrete
                      WHERE ep2.entite_fille = ra.entite AND ep2.entite_mere <> @entite);
    SET @k = CURSOR FAST_FORWARD FOR SELECT entite FROM @fil ORDER BY entite;
    OPEN @k; FETCH NEXT FROM @k INTO @f;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_arrete_porte_travail @f, @arrete, @t OUTPUT, @trouve OUTPUT;
        IF @t = 1
        BEGIN
            SET @porteur = @f;
            -- meme regle que pour le vehicule, une expertise nomme son detenteur
            IF @trouve = N'expertise'
                SET @porteur = ISNULL((SELECT TOP (1) a.entite_detentrice FROM dbo.expertise x JOIN dbo.actif a ON a.code = x.code_actif
                                       WHERE x.date_valeur = TRY_CAST(@arrete AS DATE)
                                         AND (a.entite_detentrice = @f
                                              OR a.entite_detentrice IN (SELECT g.entite_fille FROM dbo.fn_filiales_a_l_arrete(@f, @arrete) g))
                                       ORDER BY CASE WHEN a.entite_detentrice = @f THEN 0 ELSE 1 END, a.entite_detentrice), @f);
            CLOSE @k; DEALLOCATE @k;
            RETURN;
        END;
        FETCH NEXT FROM @k INTO @f;
    END;
    CLOSE @k; DEALLOCATE @k;
    DELETE dbo.ref_arrete WHERE arrete = @arrete AND entite IN (SELECT entite FROM @fil);
    DELETE dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete;
    SET @retire = 1;
END;

GO

