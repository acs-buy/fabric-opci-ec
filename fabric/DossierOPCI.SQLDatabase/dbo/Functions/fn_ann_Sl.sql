
-- Somme des soldes de plusieurs racines (oracle, Dossier.Sl) : 0 pour une liste vide, NULL sans balance sinon.
CREATE   FUNCTION dbo.fn_ann_Sl (@c INT, @a VARCHAR (20), @racines VARCHAR (400), @exclues VARCHAR (400))
RETURNS DECIMAL (38, 12)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM STRING_SPLIT(ISNULL(@racines, ''), ',') x WHERE LTRIM(RTRIM(x.value)) <> '') RETURN 0;
    IF @a IS NULL OR dbo.fn_ann_balance(@c, @a) = 0 RETURN NULL;
    RETURN ISNULL((SELECT SUM(dbo.fn_ann_S(@c, @a, LTRIM(RTRIM(x.value)), ISNULL(@exclues, ''), N'*', 0)) FROM STRING_SPLIT(@racines, ',') x
                   WHERE LTRIM(RTRIM(x.value)) <> ''), 0);
END;

GO

