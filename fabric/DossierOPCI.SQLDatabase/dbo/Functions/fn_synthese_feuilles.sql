

-- 5. LA SYNTHESE DES FEUILLES D'UN CYCLE, sur le perimetre du vehicule : par feuille, « cote : objectif,
-- forme. conclusion », l'objectif « à remplir » quand il manque, la cote d'une filiale suivie de son entite.
-- Ordre : le vehicule, puis les filiales par code, puis la cote. Une entree par ligne de v_feuilles_du_cycle.
CREATE   FUNCTION dbo.fn_synthese_feuilles (@entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10))
RETURNS NVARCHAR (MAX)
AS
BEGIN
    RETURN (SELECT STRING_AGG(
                CAST(v.cote + CASE WHEN v.entite <> v.vehicule THEN N' (' + v.entite + N')' ELSE N'' END + N' : '
                     + v.objectif_libelle + N', ' + ISNULL(v.forme_libelle, N'non conclue')
                     + CASE WHEN v.conclusion IS NOT NULL THEN N'. ' + v.conclusion ELSE N'' END
                     + CASE WHEN v.conclue_par IS NOT NULL THEN N' [' + v.conclue_par + N', ' + CONVERT(NVARCHAR (16), v.conclue_le, 120) + N']' ELSE N'' END
                     AS NVARCHAR (MAX)), NCHAR(10))
                WITHIN GROUP (ORDER BY CASE WHEN v.entite = v.vehicule THEN 0 ELSE 1 END, v.entite, v.cote)
            FROM dbo.v_feuilles_du_cycle v
            WHERE v.vehicule = @entite AND v.arrete = @arrete AND v.cycle = @cycle);
END;

GO

