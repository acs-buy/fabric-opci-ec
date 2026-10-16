-- La distribution decidee de l'exercice de la colonne (oracle, decision) : section I, categories RESULTAT et
-- EXONEREES ; section II, PLUS_VALUES. NULL sans decision.
CREATE   FUNCTION dbo.fn_ann_decision (@c INT, @a VARCHAR (20), @col TINYINT, @section VARCHAR (2))
RETURNS DECIMAL (38, 12)
AS
BEGIN
    DECLARE @x VARCHAR (20) = CASE WHEN @col = 1 THEN @a ELSE (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a) END;
    IF @x IS NULL RETURN NULL;
    DECLARE @y VARCHAR (4) = CAST(dbo.fn_ann_annee(@c, @x) AS VARCHAR (4));
    DECLARE @n INT, @s DECIMAL (38, 12);
    SELECT @n = COUNT(*), @s = ISNULL(SUM(ISNULL(d.montant_decide, 0)), 0)
    FROM dbo.decision_distribution d JOIN dbo.calcul_annexe ca ON ca.entite = d.entite
    WHERE ca.calcul_id = @c AND ((@section = 'I' AND d.categorie IN ('RESULTAT', 'EXONEREES')) OR (@section = 'II' AND d.categorie = 'PLUS_VALUES'))
      AND (CAST(d.exercice AS VARCHAR (20)) = @x OR LEFT(CAST(d.exercice AS VARCHAR (20)), 4) = @y);
    RETURN CASE WHEN @n > 0 THEN @s END;
END;

GO

