CREATE   FUNCTION dbo.fn_ann_guillemets (@lib NVARCHAR (800))
RETURNS NVARCHAR (820)
AS
BEGIN
    RETURN N'« ' + dbo.fn_ann_libelle_recueil(@lib) + N' »';
END;

GO

