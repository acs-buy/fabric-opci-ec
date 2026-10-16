
-- La distribution de l'exercice precedent (oracle, distrib_prec) : les distributions du registre datees de
-- l'exercice, moins les acomptes du 129 ; le registre n'etablit un montant que s'il est arrete a N.
CREATE   PROCEDURE dbo.pr_ann_distrib_prec @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @prev VARCHAR (20) = dbo.fn_ann_annuel_precedent(@c, @a);
    DECLARE @s129 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '129', '', N'*', 0);
    DECLARE @sg VARCHAR (4) = '-';
    IF @s129 IS NULL OR @prev IS NULL OR dbo.fn_ann_nb_porteurs(@c) = 0
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '333-3', @ligne = N'DISTRIB_PREC', @col = 1,
             @motif = N'balance, exercice précédent ou registre absent', @regle = 'A333_3', @signe = @sg;
        RETURN;
    END;
    DECLARE @haut DATE = dbo.fn_ann_date(@c, @a), @bas DATE = dbo.fn_ann_date(@c, @prev);
    IF dbo.fn_ann_parts(@c, @a) IS NULL
    BEGIN
        DECLARE @m NVARCHAR (400) = N'registre des porteurs non arrêté au ' + dbo.fn_ann_arrete_fr(@c, @a) + N' : aucun nombre de parts en circulation à cette date';
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '333-3', @ligne = N'DISTRIB_PREC', @col = 1, @motif = @m, @regle = 'A333_3', @signe = @sg;
        RETURN;
    END;
    DECLARE @dist DECIMAL (38, 12) = ISNULL((SELECT SUM(ISNULL(montant, 0)) FROM dbo.fn_ann_mvt_porteur(@c, 'DISTRIBUTION', @bas, @haut)), 0);
    DECLARE @v DECIMAL (38, 12) = @dist - @s129;
    IF @v < 0
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '333-3', @ligne = N'DISTRIB_PREC', @col = 1,
             @motif = N'registre incomplet : distributions inférieures aux acomptes', @regle = 'A333_3', @signe = @sg;
    ELSE
    BEGIN
        DECLARE @src NVARCHAR (400) = N'distributions du registre des porteurs du ' + CONVERT(NVARCHAR (10), @bas, 103) + N' exclu au ' + CONVERT(NVARCHAR (10), @haut, 103) + N' inclus, moins les acomptes du 129';
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = '333-3', @ligne = N'DISTRIB_PREC', @col = 1, @etat = 'CALCULE', @valeur = @v,
             @formule = N'distributions du registre - S(129)', @source = @src, @regle = 'A333_3', @signe = @sg;
    END;
END;

GO

