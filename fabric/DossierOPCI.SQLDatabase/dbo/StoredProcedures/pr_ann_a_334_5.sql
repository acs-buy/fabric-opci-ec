
-- ------------------------------------------------------------------------------------------------- 334-5
CREATE   PROCEDURE dbo.pr_ann_a_334_5 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '334-5';
    DECLARE @g275 VARCHAR (400) = '252:|254:|256:|258:';
    EXEC dbo.pr_ann_ligne_nature @c = @c, @a = @a, @art = @art, @code = 'PARTS_2', @comptes = '252', @exclues = '', @groupes = '275#252:|254:|256:|258:#0',
         @col_n = 1, @col_n1 = 2, @col_dim = 3, @col_aug = 4, @col_var = 5, @col_frais = 6;
    EXEC dbo.pr_ann_ligne_nature @c = @c, @a = @a, @art = @art, @code = 'PARTS_3', @comptes = '254', @exclues = '', @groupes = '275#252:|254:|256:|258:#1',
         @col_n = 1, @col_n1 = 2, @col_dim = 3, @col_aug = 4, @col_var = 5, @col_frais = 6;
    DECLARE @col TINYINT = 1;
    WHILE @col <= 6
    BEGIN
        DECLARE @t NVARCHAR (200) = N'1|334-5|PARTS_2|' + CAST(@col AS NVARCHAR (2)) + N';1|334-5|PARTS_3|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @termes = @t;
        SET @col += 1;
    END;
    EXEC dbo.pr_ann_total_hors_frais @c = @c, @a = @a, @art = @art;
    IF dbo.fn_ann_val(@c, @a, @art, N'TOTAL', 1) = 0 AND dbo.fn_ann_val(@c, @a, @art, N'TOTAL', 2) = 0
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'SECTEURS', @col = 1, @etat = 'SANS_OBJET', @fmt = 'texte', @nature = 'modele',
             @obligation = 'SANS', @regle = 'A334_5', @motif = N'aucune part détenue en N et en N-1';
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'SECTEURS', @col = 1, @motif = N'secteurs que l’OPCI détermine (p. 100)', @fmt = 'texte',
             @nature = 'texte', @regle = 'A334_5';
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @tv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', @col), @b3 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_3', @col),
                @b4 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_4', @col);
        IF @tv IS NOT NULL AND @b3 IS NOT NULL AND @b4 IS NOT NULL
        BEGIN
            DECLARE @e DECIMAL (38, 12) = @tv - @b3 - @b4, @cle NVARCHAR (40) = N'334-5 colonne ' + CAST(@col AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_BILAN', @cle = @cle, @ecart = @e;
        END;
        SET @col += 1;
    END;
END;

GO

