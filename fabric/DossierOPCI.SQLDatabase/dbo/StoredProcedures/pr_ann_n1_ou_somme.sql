
-- Colonne Exercice N-1 d'une ligne dont la colonne 1 n'est pas une somme (oracle, Table.n1_ou_somme) : la regle N quand
-- la table N-1 l'a etablie ou rendue sans objet ; sinon la somme de ses operandes de colonne 2.
CREATE   PROCEDURE dbo.pr_ann_n1_ou_somme
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @termes2 NVARCHAR (MAX),
    @regle VARCHAR (12) = NULL, @nature VARCHAR (8) = NULL, @obligation VARCHAR (14) = NULL, @fmt VARCHAR (10) = NULL,
    @etat_n1 VARCHAR (40) = NULL, @signe VARCHAR (4) = NULL, @libelle NVARCHAR (500) = NULL, @ordre DECIMAL (19, 6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @p VARCHAR (12) = dbo.fn_ann_etat(@c, @n1, @art, @ligne, 1);
    IF @p IN ('LU', 'CALCULE', 'SAISI', 'SANS_OBJET')
    BEGIN
        DECLARE @r1 VARCHAR (12) = ISNULL(@regle, 'RN'), @na1 VARCHAR (8) = ISNULL(@nature, 'source'), @ob1 VARCHAR (14) = ISNULL(@obligation, 'IMPOSEE');
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @ligne, @regle = @r1, @nature = @na1,
             @obligation = @ob1, @fmt = @fmt, @etat_n1 = @etat_n1, @signe = @signe, @libelle = @libelle, @ordre = @ordre;
    END;
    ELSE
    BEGIN
        DECLARE @r2 VARCHAR (12) = ISNULL(@regle, 'RC4'), @na2 VARCHAR (8) = ISNULL(@nature, 'calcul'),
                @ob2 VARCHAR (14) = ISNULL(@obligation, 'SANS'), @f2 VARCHAR (10) = ISNULL(@fmt, 'montant');
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = 2, @termes = @termes2, @regle = @r2,
             @nature = @na2, @obligation = @ob2, @fmt = @f2, @signe = @signe, @libelle = @libelle, @ordre = @ordre;
    END;
END;

GO

