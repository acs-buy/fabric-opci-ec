
-- Regle U (oracle, Table.regle_u) : quand le parent est connu et que toutes les composantes sauf une le sont, la
-- derniere vaut le parent moins les autres. @codes : les lignes, separees par « ; ».
CREATE   PROCEDURE dbo.pr_ann_regle_u
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @codes NVARCHAR (MAX), @col TINYINT, @parent DECIMAL (38, 12), @nom NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF @parent IS NULL RETURN;
    DECLARE @t TABLE (n INT, ligne NVARCHAR (120));
    INSERT INTO @t SELECT ordinal, LTRIM(RTRIM(value)) FROM STRING_SPLIT(@codes, N';', 1) WHERE LTRIM(RTRIM(value)) <> N'';
    IF EXISTS (SELECT 1 FROM @t t WHERE NOT EXISTS (SELECT 1 FROM dbo.annexe_w_cel w WHERE w.calcul_id = @c AND w.arrete = @a
               AND w.article = @art AND w.ligne = t.ligne AND w.colonne = @col)) RETURN;
    DECLARE @inconnues INT, @autres_connues INT, @n INT = (SELECT COUNT(*) FROM @t);
    SELECT @inconnues = SUM(CASE WHEN w.etat = 'A_REMPLIR' THEN 1 ELSE 0 END),
           @autres_connues = SUM(CASE WHEN w.etat IN ('LU', 'CALCULE', 'SAISI') THEN 1 ELSE 0 END)
    FROM @t t JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a AND w.article = @art AND w.ligne = t.ligne AND w.colonne = @col;
    IF @inconnues <> 1 OR @autres_connues <> @n - 1 RETURN;
    DECLARE @x NVARCHAR (120), @lib NVARCHAR (500), @od DECIMAL (19, 6), @ob VARCHAR (14), @fmt VARCHAR (10);
    SELECT @x = w.ligne, @lib = w.libelle, @od = w.ordre_declare, @ob = ISNULL(w.obligation, 'SANS'), @fmt = w.fmt
    FROM @t t JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a AND w.article = @art AND w.ligne = t.ligne AND w.colonne = @col
    WHERE w.etat = 'A_REMPLIR';
    DECLARE @v DECIMAL (38, 12) = @parent - ISNULL((SELECT SUM(w.valeur) FROM @t t JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a
                                             AND w.article = @art AND w.ligne = t.ligne AND w.colonne = @col WHERE t.ligne <> @x), 0);
    DECLARE @ops NVARCHAR (MAX) = (SELECT STRING_AGG(@art + N'|' + ligne + N'|' + CAST(@col AS NVARCHAR (4)), N';') WITHIN GROUP (ORDER BY n)
                                   FROM @t WHERE ligne <> @x);
    DECLARE @src NVARCHAR (MAX) = @nom + N', moins les autres composantes';
    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @x, @col = @col, @etat = 'CALCULE', @valeur = @v,
         @source = @src, @regle = 'RU', @saisie_id = 0, @ops = @ops, @libelle = @lib, @ordre = @od, @obligation = @ob, @fmt = @fmt;
END;

GO

