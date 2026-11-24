-- ------------------------------------------------------------------ le genre d'un parametre du cabinet (objet n° 19)
-- ecran 5
CREATE   FUNCTION dbo.fn_e5_genre_parametre (@code NVARCHAR (400))
RETURNS VARCHAR (12)
AS
BEGIN
    RETURN (SELECT TOP (1) p.genre FROM dbo.ref_parametre p WHERE p.code = @code);
END;

GO

