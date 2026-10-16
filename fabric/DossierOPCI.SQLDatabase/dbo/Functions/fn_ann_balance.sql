CREATE   FUNCTION dbo.fn_ann_balance (@c INT, @a VARCHAR (20))
RETURNS BIT
AS
BEGIN
    RETURN ISNULL((SELECT porte_balance FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a), 0);
END;

GO

