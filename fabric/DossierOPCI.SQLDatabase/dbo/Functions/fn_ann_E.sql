-- La ligne d'un etat, colonne 1 (exercice N) ou 2 (exercice N-1) : oracle, Dossier.E.
CREATE   FUNCTION dbo.fn_ann_E (@calcul_id INT, @arrete VARCHAR (20), @code VARCHAR (40), @k INT = 1)
RETURNS DECIMAL (38, 12)
AS
BEGIN
    RETURN (SELECT CASE @k WHEN 1 THEN exercice_n ELSE exercice_n1 END FROM dbo.annexe_w_etat
            WHERE calcul_id = @calcul_id AND arrete = @arrete AND code = @code);
END;

GO

