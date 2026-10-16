-- Une societe par sa denomination entre guillemets, a defaut le code du compte auxiliaire (oracle, Dossier.nom_entite).
CREATE   FUNCTION dbo.fn_ann_nom_entite (@code NVARCHAR (60))
RETURNS NVARCHAR (500)
AS
BEGIN
    RETURN N'« ' + ISNULL(NULLIF((SELECT denomination FROM dbo.ref_entite WHERE code = @code), N''), ISNULL(@code, N'')) + N' »';
END;

GO

