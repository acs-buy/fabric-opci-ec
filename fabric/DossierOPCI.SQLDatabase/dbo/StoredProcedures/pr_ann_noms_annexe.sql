
-- Les noms des lignes de ref_ligne_annexe (oracle, noms_lignes_annexe) : le libelle entre guillemets ; quand un autre
-- libelle de l'article est le meme, suivi de « sous » et du libelle de l'ascendant le plus proche dont le libelle est
-- unique dans l'article, a defaut de l'ascendant le plus proche ; au 335-2, une ligne du 2e tableau sans ascendant est
-- suivie de « du tableau « Evolution des dépréciations » » ; les intitules de colonnes du 336-2 ne prennent pas
-- d'ascendant.
CREATE   PROCEDURE dbo.pr_ann_noms_annexe @c INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE dbo.annexe_w_nom WHERE calcul_id = @c;
    DECLARE @l TABLE (article VARCHAR (10), i INT, code VARCHAR (24), libelle NVARCHAR (800), cle NVARCHAR (800), niveau INT, type_ligne VARCHAR (14), nb INT,
                      PRIMARY KEY (article, i));
    INSERT INTO @l (article, i, code, libelle, cle, niveau, type_ligne)
    SELECT article, ROW_NUMBER() OVER (PARTITION BY article ORDER BY ordre, code), code, libelle, dbo.fn_ann_libelle_recueil(libelle), ISNULL(niveau, 0), type_ligne
    FROM dbo.ref_ligne_annexe;
    UPDATE x SET nb = (SELECT COUNT(*) FROM @l y WHERE y.article = x.article AND y.cle = x.cle) FROM @l x;
    INSERT INTO dbo.annexe_w_nom (calcul_id, article, code, nom) SELECT @c, article, code, dbo.fn_ann_guillemets(libelle) FROM @l;
    DECLARE @art VARCHAR (10), @i INT, @code VARCHAR (24), @niv INT, @debut2 INT, @j INT, @yniv INT, @yi INT, @asc_unique INT, @asc_premier INT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT article, i, code, niveau FROM @l WHERE nb > 1 AND NOT (article = '336-2' AND code NOT IN ('FIL_CONTROLEES', 'FIL_NON_CONTROLEES')) ORDER BY article, i;
    OPEN cur; FETCH NEXT FROM cur INTO @art, @i, @code, @niv;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @debut2 = CASE WHEN @art = '335-2' THEN (SELECT MIN(i) + 1 FROM @l WHERE article = @art AND type_ligne = 'TOTAL' AND niveau = 0) END;
        DECLARE @deuxieme BIT = CASE WHEN @debut2 IS NOT NULL AND @i >= @debut2 THEN 1 ELSE 0 END;
        SELECT @j = @i - 1, @asc_unique = NULL, @asc_premier = NULL;
        WHILE @j >= CASE WHEN @deuxieme = 1 THEN @debut2 ELSE 1 END
        BEGIN
            SELECT @yniv = niveau FROM @l WHERE article = @art AND i = @j;
            IF @yniv < @niv
            BEGIN
                IF @asc_premier IS NULL SET @asc_premier = @j;
                IF @asc_unique IS NULL AND (SELECT nb FROM @l WHERE article = @art AND i = @j) = 1 SET @asc_unique = @j;
                SET @niv = @yniv;
            END;
            SET @j -= 1;
        END;
        SET @yi = ISNULL(@asc_unique, @asc_premier);
        IF @yi IS NOT NULL
            UPDATE dbo.annexe_w_nom SET nom = nom + N' sous ' + (SELECT dbo.fn_ann_guillemets(libelle) FROM @l WHERE article = @art AND i = @yi)
            WHERE calcul_id = @c AND article = @art AND code = @code;
        ELSE IF @deuxieme = 1
            UPDATE dbo.annexe_w_nom SET nom = nom + N' du tableau « Evolution des dépréciations »' WHERE calcul_id = @c AND article = @art AND code = @code;
        FETCH NEXT FROM cur INTO @art, @i, @code, @niv;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

