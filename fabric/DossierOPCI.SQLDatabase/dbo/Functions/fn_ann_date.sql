CREATE   FUNCTION dbo.fn_ann_date (@c INT, @a VARCHAR (20))
RETURNS DATE
AS
BEGIN
    RETURN (SELECT date_arrete FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
END;

GO

