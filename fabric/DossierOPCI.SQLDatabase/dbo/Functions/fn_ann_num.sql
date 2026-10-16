CREATE   FUNCTION dbo.fn_ann_num (@c INT, @cle VARCHAR (20), @a VARCHAR (20))
RETURNS DECIMAL (38, 12)
AS
BEGIN
    RETURN (SELECT valeur FROM dbo.annexe_w_num WHERE calcul_id = @c AND cle = @cle AND arrete = @a);
END;

GO

