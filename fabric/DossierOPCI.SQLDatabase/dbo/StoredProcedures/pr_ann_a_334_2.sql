
-- ------------------------------------------------------------------------------------------------- 334-2
CREATE   PROCEDURE dbo.pr_ann_a_334_2 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '334-2';
    DECLARE @g271 VARCHAR (400) = '211:|213:|214:|21:211,213,214', @g272 VARCHAR (400) = '221,228:|22:221,228', @g273 VARCHAR (400) = '23:';
    DECLARE @l TABLE (n INT, code VARCHAR (24), comptes VARCHAR (400), exclues VARCHAR (400), groupes VARCHAR (4000));
    INSERT INTO @l VALUES
        (1, 'TERRAINS_NUS', '211', '', '271#' + @g271 + '#0'),
        (2, 'TERRAINS_CONSTR', '213', '', '271#' + @g271 + '#1'),
        (3, 'SOL_AUTRUI', '214', '', '271#' + @g271 + '#2'),
        (4, 'DROITS_REELS', '23', '', '273#' + @g273 + '#0'),
        (5, 'EN_COURS', '221,228', '', '272#' + @g272 + '#0'),
        (6, 'AUTRES', '21,22', '211,213,214,221,228', '271#' + @g271 + '#3~272#' + @g272 + '#1');
    DECLARE @code VARCHAR (24), @cs VARCHAR (400), @ex VARCHAR (400), @gr VARCHAR (4000);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code, comptes, exclues, groupes FROM @l ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code, @cs, @ex, @gr;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_ligne_nature @c = @c, @a = @a, @art = @art, @code = @code, @comptes = @cs, @exclues = @ex, @groupes = @gr,
             @col_n = 1, @col_n1 = 2, @col_aug = 3, @col_dim = 4, @col_var = 5, @col_frais = 6;
        FETCH NEXT FROM cur INTO @code, @cs, @ex, @gr;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE @col TINYINT = 1;
    WHILE @col <= 6
    BEGIN
        DECLARE @t NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|334-2|' + code + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @l);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @termes = @t;
        SET @col += 1;
    END;
    EXEC dbo.pr_ann_total_hors_frais @c = @c, @a = @a, @art = @art;
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @tv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', @col), @b DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_1', @col);
        IF @tv IS NOT NULL AND @b IS NOT NULL
        BEGIN
            DECLARE @e DECIMAL (38, 12) = @tv - @b, @cle NVARCHAR (40) = N'334-2 colonne ' + CAST(@col AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_BILAN', @cle = @cle, @ecart = @e;
        END;
        SET @col += 1;
    END;
END;

GO

