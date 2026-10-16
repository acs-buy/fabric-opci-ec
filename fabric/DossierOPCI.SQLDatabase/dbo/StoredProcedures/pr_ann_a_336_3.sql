
-- ------------------------------------------------------------------------------------------------- 336-3
CREATE   PROCEDURE dbo.pr_ann_a_336_3 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s_fin NVARCHAR (MAX) = N'bilan actif, somme des lignes du poste ' + dbo.fn_ann_nom_etat('A_FIN');
    DECLARE @art VARCHAR (10) = '336-3', @n INT, @s DECIMAL (38, 12), @v DECIMAL (38, 12);
    SELECT @n = COUNT(dbo.fn_ann_E(@c, @a, 'A_FIN_' + CAST(k AS VARCHAR (2)), 1)), @s = SUM(dbo.fn_ann_E(@c, @a, 'A_FIN_' + CAST(k AS VARCHAR (2)), 1))
    FROM (VALUES (1), (2), (3), (4), (5), (6), (7)) x (k);
    SET @v = CASE WHEN @n = 7 THEN @s END;
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'VALEUR', @col = 1, @v = @v, @source = @s_fin,
         @nature = 'etat', @regle = 'RC10', @motif = N'bilan absent';
    IF @v = 0
    BEGIN
        EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = N'LIBELLE', @col = 1, @source = N'rubrique du bilan nulle';
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'QUANTITE', @col = 1, @motif = N'rubrique du bilan nulle', @regle = 'NEANT', @fmt = 'nombre';
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'DEVISE', @col = 1, @motif = N'rubrique du bilan nulle', @regle = 'NEANT', @fmt = 'texte';
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'PCT', @col = 1, @motif = N'rubrique du bilan nulle', @regle = 'NEANT', @fmt = 'pct';
    END;
    ELSE
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'LIBELLE', @col = 1, @motif = N'inventaire par instrument absent de la base', @fmt = 'texte', @nature = 'texte', @regle = 'TXT';
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'QUANTITE', @col = 1, @motif = N'inventaire par instrument absent de la base', @fmt = 'nombre', @nature = 'source', @regle = 'TXT';
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'DEVISE', @col = 1, @motif = N'inventaire par instrument absent de la base', @fmt = 'texte', @nature = 'texte', @regle = 'TXT';
        EXEC dbo.pr_ann_pct @c = @c, @a = @a, @art = @art, @ligne = N'PCT', @col = 1, @n_art = @art, @n_ligne = N'VALEUR', @n_col = 1, @regle = 'RC4';
    END;
END;

GO

