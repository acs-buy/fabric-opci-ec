
-- « Total frais exclus » (oracle, total_hors_frais) : une seule cellule, fusionnee sur Exercice N et Frais (p. 100).
CREATE   PROCEDURE dbo.pr_ann_total_hors_frais @c INT, @a VARCHAR (20), @art VARCHAR (10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @t NVARCHAR (100) = N'1|' + @art + N'|TOTAL|1';
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL_HORS_FRAIS', @col = 1, @termes = @t, @formule = N'TOTAL[1]';
    DECLARE @col TINYINT = 2;
    WHILE @col <= 6
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL_HORS_FRAIS', @col = @col,
             @motif = N'« Total frais exclus » : une cellule fusionnée sur Exercice N et Frais (p. 100)', @regle = 'RC1';
        SET @col += 1;
    END;
END;

GO

