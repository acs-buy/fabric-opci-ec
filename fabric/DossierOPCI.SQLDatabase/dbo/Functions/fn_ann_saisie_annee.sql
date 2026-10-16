
-- La saisie d'une ligne du 332-1 pour l'exercice @y (oracle, saisie_annee) : faite a N, ou a un arrete annuel anterieur,
-- dans la colonne qui designait @y ; la plus recente par saisi_le, puis par la date de son arrete. 0 sans saisie.
CREATE   FUNCTION dbo.fn_ann_saisie_annee (@c INT, @a VARCHAR (20), @ligne NVARCHAR (120), @y INT)
RETURNS INT
AS
BEGIN
    DECLARE @dn DATE = dbo.fn_ann_date(@c, @a);
    RETURN ISNULL((
        SELECT TOP (1) s.id FROM dbo.saisie_annexe s
        JOIN dbo.calcul_annexe ca ON ca.entite = s.entite
        JOIN dbo.annexe_w_arr x ON x.calcul_id = @c AND x.arrete = s.arrete
        WHERE ca.calcul_id = @c AND s.article = '332-1' AND s.ligne = @ligne AND LTRIM(RTRIM(s.colonne)) NOT LIKE N'%[^0-9]%' AND LTRIM(RTRIM(s.colonne)) <> N''
          AND x.date_arrete <= @dn AND (s.arrete = @a OR x.type_arrete = 'ANNUEL')
          AND x.annee - (CAST(LTRIM(RTRIM(s.colonne)) AS INT) - 1) = @y
        ORDER BY CONVERT(VARCHAR (30), s.saisi_le, 121) DESC, x.date_arrete DESC), 0);
END;

GO

