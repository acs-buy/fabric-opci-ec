
-- --- 2. la premiere cloture a venir d'une entite -----------------------------------------------
-- ref_entite.cloture s'ecrit « 31/12 » ou « 31-12 », les 2 formes vivent sur le jeu.
CREATE   FUNCTION dbo.fn_prochaine_cloture (@entite VARCHAR (20), @depuis DATE)
RETURNS DATE
AS
BEGIN
    DECLARE @c CHAR (5) = (SELECT cloture FROM dbo.ref_entite WHERE code = @entite);
    IF @c IS NULL RETURN NULL;
    DECLARE @jour INT = TRY_CAST(LEFT(@c, 2) AS INT), @mois INT = TRY_CAST(RIGHT(@c, 2) AS INT);
    IF @jour IS NULL OR @mois IS NULL RETURN NULL;
    DECLARE @d DATE = DATEFROMPARTS(YEAR(@depuis), @mois, 1);
    SET @d = EOMONTH(@d);                                   -- le dernier jour du mois de cloture
    IF @jour < DAY(@d) SET @d = DATEFROMPARTS(YEAR(@d), @mois, @jour);
    IF @d < @depuis SET @d = DATEADD(YEAR, 1, @d);
    RETURN @d;
END;

GO

