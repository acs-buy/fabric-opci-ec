-- ------------------------------------------------------------------ le genre d'un parametre du cabinet (objet n° 19)
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   FUNCTION dbo.fn_e5_genre_parametre (@code NVARCHAR (400))
RETURNS VARCHAR (12)
AS
BEGIN
    RETURN (SELECT TOP (1) p.genre FROM dbo.ref_parametre p WHERE p.code = @code);
END;

GO

