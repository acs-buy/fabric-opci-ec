
-- ------------------------------------------------------------------------------------------------- 335-5
CREATE   PROCEDURE dbo.pr_ann_a_335_5 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s_p NVARCHAR (MAX), @s_det NVARCHAR (MAX) = N'bilan passif, ligne ' + dbo.fn_ann_nom_etat('P_DET_1');
    DECLARE @art VARCHAR (10) = '335-5', @col TINYINT, @code VARCHAR (24), @t NVARCHAR (MAX);
    DECLARE @r TABLE (n INT, code VARCHAR (24));
    INSERT INTO @r VALUES (1, 'TF'), (2, 'TV');
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM @r ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @col = 1;
        WHILE @col <= 4
        BEGIN
            EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'rubrique', @regle = 'RC1';
            SET @col += 1;
        END;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE @l TABLE (n INT, code VARCHAR (24));
    INSERT INTO @l VALUES (1, 'TF_AMORT'), (2, 'TF_IN_FINE'), (3, 'TV_AMORT'), (4, 'TV_IN_FINE');
    DECLARE @ec DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, '335-4', N'EC', 1);
    SET @s_p = dbo.fn_ann_designer(@c, @a, '335-4', N'EC', 1) + N', nulle : chaque composante est nulle';
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM @l ORDER BY n;
    OPEN cur2; FETCH NEXT FROM cur2 INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @col = 1;
        WHILE @col <= 3
        BEGIN
            IF @ec = 0
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @etat = 'CALCULE', @valeur = 0, @source = @s_p, @regle = 'RP';
            ELSE
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'durée restant à courir, absente de la base', @regle = 'RP';
            SET @col += 1;
        END;
        SET @t = N'1|335-5|' + @code + N'|1;1|335-5|' + @code + N'|2;1|335-5|' + @code + N'|3';
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 4, @termes = @t;
        FETCH NEXT FROM cur2 INTO @code;
    END;
    CLOSE cur2; DEALLOCATE cur2;
    SET @col = 1;
    WHILE @col <= 3
    BEGIN
        SET @t = (SELECT STRING_AGG(N'1|335-5|' + code + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @l);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @termes = @t;
        SET @col += 1;
    END;
    DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'P_DET_1', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = 4, @v = @v, @source = @s_det, @nature = 'etat',
         @obligation = 'IMPOSEE', @regle = 'RC10';
    DECLARE @tt DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', 4), @n INT, @s DECIMAL (38, 12);
    SELECT @n = COUNT(dbo.fn_ann_val(@c, @a, @art, code, 4)), @s = SUM(dbo.fn_ann_val(@c, @a, @art, code, 4)) FROM @l;
    IF @tt IS NOT NULL AND @n = 4
    BEGIN
        DECLARE @e DECIMAL (38, 12) = @s - @tt;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_5_TOTAL', @cle = N'colonne Total', @ecart = @e;
    END;
END;

GO

