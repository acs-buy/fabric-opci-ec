
-- La distribution de l'exercice precedent @v (333-3 de l'arrete @a) rapprochee du registre des porteurs (oracle,
-- distrib_prec_rapprochee) : NULL quand elle l'est, le motif sinon.
CREATE   FUNCTION dbo.fn_ann_distrib_prec_motif (@c INT, @v DECIMAL (38, 12), @a_prec VARCHAR (20), @a VARCHAR (20))
RETURNS NVARCHAR (800)
AS
BEGIN
    DECLARE @s129 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '129', '', N'*', 0);
    DECLARE @bas DATE = dbo.fn_ann_date(@c, @a_prec), @haut DATE = dbo.fn_ann_date(@c, @a);
    DECLARE @n INT, @tot DECIMAL (38, 12);
    SELECT @n = COUNT(*), @tot = ISNULL(SUM(ISNULL(montant, 0)), 0) FROM dbo.fn_ann_mvt_porteur(@c, 'DISTRIBUTION', @bas, @haut);
    IF @s129 IS NULL
    BEGIN
        IF @n = 0 AND @v = 0 RETURN NULL;
        RETURN N'distribution de l’exercice précédent (' + dbo.fn_ann_format('montant', @v) + N', 333-3 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a) + N') non rapprochée : arrêté sans balance';
    END;
    IF dbo.fn_ann_nb_porteurs(@c) = 0 OR dbo.fn_ann_parts(@c, @a) IS NULL
        RETURN N'distribution de l’exercice précédent (' + dbo.fn_ann_format('montant', @v) + N', 333-3 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a)
             + N') non rapprochée : registre des porteurs absent ou non arrêté à cet arrêté';
    IF @v <> @tot - @s129
        RETURN N'distribution de l’exercice précédent (' + dbo.fn_ann_format('montant', @v) + N', 333-3 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a)
             + N') non rapprochée des distributions du registre des porteurs datées de l’exercice ('
             + dbo.fn_ann_format('montant', @tot) + N') moins les acomptes du 129 (' + dbo.fn_ann_format('montant', @s129) + N')';
    RETURN NULL;
END;

GO

