
-- Article de principe : aucune cellule, sauf pour porter une saisie ecartee (oracle, principe).
CREATE   PROCEDURE dbo.pr_ann_principe @c INT, @a VARCHAR (20), @art VARCHAR (10)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_ann_ligne_retiree @c = @c, @a = @a, @art = @art, @ligne = N'PRINCIPE', @regle = 'FAC',
         @motif = N'principe imprimé en paragraphe ; le recueil ne demande aucune information';
END;

GO

