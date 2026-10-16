
-- Obligation d'une information demandee « le cas echeant » (oracle, cas_echeant) : IMPOSEE quand une des lignes du
-- compte de resultat n'est pas nulle, 'NEANT' quand toutes sont nulles, CONDITIONNELLE quand la base ne le dit pas.
CREATE   FUNCTION dbo.fn_ann_cas_echeant (@c INT, @a VARCHAR (20), @lignes VARCHAR (400))
RETURNS VARCHAR (14)
AS
BEGIN
    DECLARE @n INT, @connues INT, @non_nulles INT;
    SELECT @n = COUNT(*),
           @connues = SUM(CASE WHEN e.exercice_n IS NOT NULL THEN 1 ELSE 0 END),
           @non_nulles = SUM(CASE WHEN e.exercice_n IS NOT NULL AND e.exercice_n <> 0 THEN 1 ELSE 0 END)
    FROM STRING_SPLIT(@lignes, ',') x
    LEFT JOIN dbo.annexe_w_etat e ON e.calcul_id = @c AND e.arrete = @a AND e.code = LTRIM(RTRIM(x.value));
    IF @non_nulles > 0 RETURN 'IMPOSEE';
    IF @connues = @n RETURN 'NEANT';
    RETURN 'CONDITIONNELLE';
END;

GO

