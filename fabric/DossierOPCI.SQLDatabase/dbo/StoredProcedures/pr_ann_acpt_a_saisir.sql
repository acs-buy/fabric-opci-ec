
-- ------------------------------------------------------------------------------------------------- 335-12, acomptes
-- Une cellule saisissable d'un tableau des acomptes (oracle, acomptes.a_saisir) : a remplir au tableau de l'exercice
-- (@k = 1) ; regle N au tableau de l'exercice precedent (@k = 2), sur la meme cellule du tableau de l'exercice de N-1.
CREATE   PROCEDURE dbo.pr_ann_acpt_a_saisir @c INT, @a VARCHAR (20), @k INT, @prefixe VARCHAR (10), @l NVARCHAR (120), @col TINYINT,
                                               @motif NVARCHAR (MAX), @fmt VARCHAR (10) = NULL, @nature VARCHAR (8) = 'source',
                                               @libelle NVARCHAR (500), @ordre DECIMAL (19, 6)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-12';
    IF @k = 1
    BEGIN
        DECLARE @f1 VARCHAR (10) = ISNULL(@fmt, 'montant');
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = @motif, @fmt = @f1, @nature = @nature, @regle = 'ACPT',
             @libelle = @libelle, @ordre = @ordre;
        RETURN;
    END;
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @de NVARCHAR (120) = N'ACPT_N' + SUBSTRING(@l, LEN(@prefixe) + 1, 120);
    DECLARE @prec_existe BIT = CASE WHEN EXISTS (SELECT 1 FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @n1) THEN 1 ELSE 0 END;
    IF @prec_existe = 1 AND dbo.fn_ann_etat(@c, @n1, @art, @de, @col) IS NULL
    BEGIN
        DECLARE @m2 NVARCHAR (MAX) = @motif + N' ; ligne absente du tableau des acomptes de l’exercice de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @n1), @f2 VARCHAR (10) = ISNULL(@fmt, 'montant');
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = @m2, @fmt = @f2, @nature = @nature, @regle = 'ACPT',
             @libelle = @libelle, @ordre = @ordre;
        RETURN;
    END;
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @de_art = '335-12', @de_ligne = @de, @de_col = @col,
         @fmt = @fmt, @nature = @nature, @libelle = @libelle, @ordre = @ordre;
END;

GO

