-- Une cellule dans un motif ou une source (oracle, Table.designer) : « article, ligne « libellé », colonne n ».
CREATE   FUNCTION dbo.fn_ann_designer (@c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT)
RETURNS NVARCHAR (2200)
AS
BEGIN
    RETURN @art + N', ' + dbo.fn_ann_nom_ligne(@c, @a, @art, @ligne) + N', colonne ' + CAST(@col AS NVARCHAR (4));
END;

GO

