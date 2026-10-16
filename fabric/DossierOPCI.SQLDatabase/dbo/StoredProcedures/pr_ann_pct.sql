
-- Pourcentage de l'actif net (oracle, pct) : la valeur sur 333-3 AN_FIN colonne 1 ; en attente tant que l'un manque.
CREATE   PROCEDURE dbo.pr_ann_pct @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT,
                                     @n_art VARCHAR (10), @n_ligne NVARCHAR (120), @n_col TINYINT, @regle VARCHAR (12),
                                     @libelle NVARCHAR (500) = NULL, @ordre DECIMAL (19, 6) = NULL, @groupe VARCHAR (40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ops NVARCHAR (400) = @n_art + N'|' + @n_ligne + N'|' + CAST(@n_col AS NVARCHAR (2)) + N';333-3|AN_FIN|1';
    DECLARE @vn DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @n_art, @n_ligne, @n_col), @an DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, '333-3', N'AN_FIN', 1);
    IF @vn IS NOT NULL AND @an IS NOT NULL AND @an <> 0
    BEGIN
        DECLARE @v DECIMAL (38, 12) = CAST(CAST(@vn AS FLOAT) / CAST(@an AS FLOAT) AS DECIMAL (38, 12));
        DECLARE @src NVARCHAR (MAX) = dbo.fn_ann_designer(@c, @a, @n_art, @n_ligne, @n_col) + N', divisée par ' + dbo.fn_ann_designer(@c, @a, '333-3', N'AN_FIN', 1);
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'CALCULE', @valeur = @v, @fmt = 'pct', @ops = @ops,
             @source = @src, @nature = 'calcul', @obligation = 'SANS', @regle = @regle, @libelle = @libelle, @ordre = @ordre, @groupe = @groupe;
    END;
    ELSE
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'EN_ATTENTE', @fmt = 'pct', @ops = @ops,
             @motif = N'valeur ou actif net à remplir', @nature = 'calcul', @obligation = 'SANS', @regle = @regle, @libelle = @libelle,
             @ordre = @ordre, @groupe = @groupe;
END;

GO

