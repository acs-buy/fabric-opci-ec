-- Colonne Exercice N-1 des composantes d'un parent (oracle, composantes_n1) : la regle N quand N-1 l'etablit ; sinon la
-- regle P sur le parent de la colonne 2 ; sinon la regle N (a remplir) ; puis la regle U.
CREATE   PROCEDURE dbo.pr_ann_composantes_n1 @c INT, @a VARCHAR (20), @art VARCHAR (10), @parent VARCHAR (24), @codes VARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @pv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @parent, 2), @code VARCHAR (24);
    DECLARE @nom_p NVARCHAR (MAX) = dbo.fn_ann_nom_ligne(@c, @a, @art, @parent);
    DECLARE @src NVARCHAR (MAX) = @nom_p + N', colonne 2, nulle : chaque composante est nulle';
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT LTRIM(RTRIM(value)) FROM STRING_SPLIT(@codes, ',', 1) ORDER BY ordinal;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF dbo.fn_ann_connue(@c, @n1, @art, @code, 1) = 1
            EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        ELSE IF @pv = 0
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2, @etat = 'CALCULE', @valeur = 0, @source = @src, @regle = 'RP';
        ELSE
            EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE @cs NVARCHAR (400) = REPLACE(@codes, ',', ';');
    EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = @cs, @col = 2, @parent = @pv, @nom = @nom_p;
END;

GO

