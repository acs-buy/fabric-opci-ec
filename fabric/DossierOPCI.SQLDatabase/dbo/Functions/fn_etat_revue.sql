
CREATE   FUNCTION dbo.fn_etat_revue (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS VARCHAR (12)
AS
BEGIN
    DECLARE @c DATETIME2 (3) = (SELECT conclu_le FROM dbo.conclusion_revue WHERE entite = @entite AND arrete = @arrete);
    DECLARE @d VARCHAR (8), @le DATETIME2 (3);
    SELECT TOP (1) @d = decision, @le = decide_le FROM dbo.visa
    WHERE nature = 'REVUE' AND objet_ref = @entite + '|' + @arrete ORDER BY decide_le DESC, id DESC;
    -- un dossier vise puis deverrouille sans conclusion relue reste RENVOYEE ; sans conclusion du tout, A_CONCLURE
    IF @c IS NULL RETURN 'A_CONCLURE';
    IF @d IS NULL OR @le <= @c RETURN 'CONCLUE';
    RETURN CASE WHEN @d = 'VISE' THEN 'VISEE' ELSE 'RENVOYEE' END;
END;

GO

