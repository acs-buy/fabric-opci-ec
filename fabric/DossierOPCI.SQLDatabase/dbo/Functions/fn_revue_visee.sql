
-- la derniere decision REVUE est VISE
CREATE   FUNCTION dbo.fn_revue_visee (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN (SELECT TOP (1) decision FROM dbo.visa WHERE nature = 'REVUE' AND objet_ref = @entite + '|' + @arrete
                      ORDER BY decide_le DESC, id DESC) = 'VISE' THEN 1 ELSE 0 END;
END;

GO

