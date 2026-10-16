-- Le poste du bilan d'un actif detenu par l'entite commence par l'une des racines et par aucune des exclues.
CREATE   FUNCTION dbo.fn_ann_poste_ok (@c INT, @code_actif VARCHAR (40), @comptes VARCHAR (400), @exclues VARCHAR (400))
RETURNS BIT
AS
BEGIN
    DECLARE @p VARCHAR (40) = ISNULL((SELECT x.poste_bilan FROM dbo.actif x JOIN dbo.calcul_annexe ca ON ca.entite = x.entite_detentrice
                                      WHERE ca.calcul_id = @c AND x.code = @code_actif), '');
    IF NOT EXISTS (SELECT 1 FROM STRING_SPLIT(@comptes, ',') y WHERE LTRIM(RTRIM(y.value)) <> '' AND @p LIKE LTRIM(RTRIM(y.value)) + '%') RETURN 0;
    IF EXISTS (SELECT 1 FROM STRING_SPLIT(@exclues, ',') y WHERE LTRIM(RTRIM(y.value)) <> '' AND @p LIKE LTRIM(RTRIM(y.value)) + '%') RETURN 0;
    RETURN 1;
END;

GO

