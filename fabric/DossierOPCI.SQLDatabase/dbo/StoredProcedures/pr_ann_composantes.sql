-- Composantes d'un parent de la colonne Exercice N (oracle, composantes) : regle P sur un parent nul, sinon a remplir ;
-- puis la regle U.
CREATE   PROCEDURE dbo.pr_ann_composantes @c INT, @a VARCHAR (20), @art VARCHAR (10), @parent VARCHAR (24), @parent_col TINYINT,
                                             @codes VARCHAR (400), @col TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @pv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @parent, @parent_col), @code VARCHAR (24);
    DECLARE @nom_p NVARCHAR (MAX) = dbo.fn_ann_nom_ligne(@c, @a, @art, @parent);
    DECLARE @src NVARCHAR (MAX) = @nom_p + N', colonne ' + CAST(@parent_col AS NVARCHAR (4)) + N', nulle : chaque composante est nulle';
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@codes, ',', 1) ORDER BY ordinal;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @pv = 0
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @etat = 'CALCULE', @valeur = 0, @source = @src, @regle = 'RP';
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'ventilation absente de la base', @regle = 'RP';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE @cs NVARCHAR (400) = REPLACE(@codes, ',', ';');
    EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = @cs, @col = @col, @parent = @pv, @nom = @nom_p;
END;

GO

