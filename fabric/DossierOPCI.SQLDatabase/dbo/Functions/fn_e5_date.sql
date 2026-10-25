-- ------------------------------------------------------------------ une date saisie jj/mm/aaaa (style 103) ; NULL sinon
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   FUNCTION dbo.fn_e5_date (@texte NVARCHAR (40))
RETURNS DATE
AS
BEGIN
    DECLARE @s NVARCHAR (40) = LTRIM(RTRIM(@texte));
    IF @s IS NULL OR NOT (@s LIKE N'[0-9]/[0-9]/[0-9][0-9][0-9][0-9]' OR @s LIKE N'[0-9][0-9]/[0-9]/[0-9][0-9][0-9][0-9]'
                          OR @s LIKE N'[0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' OR @s LIKE N'[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]')
        RETURN NULL;
    RETURN TRY_CONVERT(DATE, @s, 103);
END;

GO

