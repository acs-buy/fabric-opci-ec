-- Regle D (oracle, de) : difference d'estimation du membre @i (0, 1...) du groupe du compte @d a l'arrete ; rend la
-- valeur et la sous-regle D0 a D4.
CREATE   FUNCTION dbo.fn_ann_de (@c INT, @a VARCHAR (20), @d VARCHAR (10), @membres VARCHAR (2000), @i INT)
RETURNS @r TABLE (v DECIMAL (38, 12) NULL, regle VARCHAR (20))
AS
BEGIN
    DECLARE @m TABLE (j INT, comptes VARCHAR (400), exclues VARCHAR (400));
    INSERT INTO @m SELECT x.ordinal - 1, LEFT(x.value, CHARINDEX(':', x.value + ':') - 1), SUBSTRING(x.value, CHARINDEX(':', x.value + ':') + 1, 400)
    FROM STRING_SPLIT(@membres, '|', 1) x;
    DECLARE @comptes VARCHAR (400), @exclues VARCHAR (400);
    SELECT @comptes = comptes, @exclues = exclues FROM @m WHERE j = @i;
    DECLARE @cout DECIMAL (38, 12) = dbo.fn_ann_Sl(@c, @a, @comptes, @exclues);
    IF @cout IS NULL BEGIN INSERT INTO @r VALUES (NULL, 'sans balance'); RETURN; END;
    IF @cout = 0 BEGIN INSERT INTO @r VALUES (0, 'D0'); RETURN; END;
    DECLARE @sd DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, @d, '', N'*', 0);
    IF @sd = 0 BEGIN INSERT INTO @r VALUES (0, 'D1'); RETURN; END;
    IF NOT EXISTS (SELECT 1 FROM @m WHERE j <> @i AND dbo.fn_ann_Sl(@c, @a, comptes, exclues) <> 0)
        BEGIN INSERT INTO @r VALUES (@sd, 'D2'); RETURN; END;
    IF EXISTS (SELECT 1 FROM dbo.annexe_w_axe WHERE calcul_id = @c AND arrete = @a AND compte_num LIKE @d + '%')
       AND NOT EXISTS (SELECT 1 FROM dbo.annexe_w_axe WHERE calcul_id = @c AND arrete = @a AND compte_num LIKE @d + '%' AND ISNULL(code_actif, '') = '')
    BEGIN
        INSERT INTO @r SELECT ISNULL(SUM(CASE WHEN dbo.fn_ann_poste_ok(@c, code_actif, @comptes, @exclues) = 1 THEN solde END), 0), 'D3'
        FROM dbo.annexe_w_axe WHERE calcul_id = @c AND arrete = @a AND compte_num LIKE @d + '%';
        RETURN;
    END;
    INSERT INTO @r VALUES (NULL, 'D4');
    RETURN;
END;

GO

