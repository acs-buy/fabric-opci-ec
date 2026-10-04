
-- LE MESSAGE D'UNE LIGNE, sans son entete « Ligne refusee : » quand un prefixe dit deja la ligne.
CREATE   FUNCTION dbo.fn_sans_entete_ligne (@m NVARCHAR (2000))
RETURNS NVARCHAR (2000)
AS
BEGIN
    RETURN CASE WHEN @m LIKE N'Ligne refusée : %' THEN SUBSTRING(@m, LEN(N'Ligne refusée : x'), 2000) ELSE @m END;
END;

GO

