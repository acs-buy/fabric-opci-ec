
-- Une ligne que la regle retire n'a de cellule que pour porter une saisie existante, ecartee (oracle, ligne_retiree).
CREATE   PROCEDURE dbo.pr_ann_ligne_retiree @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120),
                                                @regle VARCHAR (12), @motif NVARCHAR (MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    IF EXISTS (SELECT 1 FROM dbo.saisie_annexe WHERE entite = @entite AND arrete = @a AND article = @art AND ligne = @ligne
               AND LTRIM(RTRIM(colonne)) = N'1')
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = 1, @motif = @motif, @fmt = 'texte', @regle = @regle;
END;

GO

