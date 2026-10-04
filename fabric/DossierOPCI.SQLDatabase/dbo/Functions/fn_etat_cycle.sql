
-- 2. LES ETATS. Cycle : A_CONCLURE, CONCLU, VISE, RENVOYE. Revue : A_CONCLURE, CONCLUE, VISEE, RENVOYEE.
-- Une decision ne compte que si elle est posterieure a la conclusion en vigueur.
CREATE   FUNCTION dbo.fn_etat_cycle (@entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10))
RETURNS VARCHAR (12)
AS
BEGIN
    DECLARE @c DATETIME2 (3) = (SELECT conclu_le FROM dbo.conclusion_cycle WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle);
    IF @c IS NULL RETURN 'A_CONCLURE';
    DECLARE @d VARCHAR (8), @le DATETIME2 (3);
    SELECT TOP (1) @d = decision, @le = decide_le FROM dbo.visa
    WHERE nature = 'CYCLE' AND objet_ref = @entite + '|' + @arrete + '|' + @cycle ORDER BY decide_le DESC, id DESC;
    IF @d IS NULL OR @le <= @c RETURN 'CONCLU';
    RETURN CASE WHEN @d = 'VISE' THEN 'VISE' ELSE 'RENVOYE' END;
END;

GO

