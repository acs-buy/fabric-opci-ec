
-- 335-9 : autres produits et charges, le cas echeant.
CREATE   PROCEDURE dbo.pr_ann_a_335_9 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s9 NVARCHAR (MAX) = N'compte de résultat, lignes ' + dbo.fn_ann_nom_etat('R_TV') + N' et ' + dbo.fn_ann_nom_etat('R_TVII') + N' nulles';
    DECLARE @ob VARCHAR (14) = dbo.fn_ann_cas_echeant(@c, @a, 'R_TV,R_TVII');
    IF @ob = 'NEANT'
        EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = '335-9', @ligne = N'DETAIL', @col = 1, @source = @s9,
             @obligation = 'CONDITIONNELLE';
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '335-9', @ligne = N'DETAIL', @col = 1,
             @motif = N'autres produits et charges à détailler', @fmt = 'texte', @nature = 'texte', @obligation = @ob, @regle = 'TXT';
END;

GO

