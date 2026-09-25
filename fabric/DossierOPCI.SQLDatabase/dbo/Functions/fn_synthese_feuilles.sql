-- La synthese des feuilles d'un cycle : une ligne par feuille, cote, gabarit, forme et texte de conclusion,
-- « (non conclue) » sinon. L'objectif et la methodologie vivent dans le classeur, pas en colonne : ils ne
-- sont pas repris ici, le besoin le note.
CREATE   FUNCTION dbo.fn_synthese_feuilles (@entite VARCHAR (20), @arrete VARCHAR (20), @cycle VARCHAR (10))
RETURNS NVARCHAR (MAX)
AS
BEGIN
    RETURN (SELECT STRING_AGG(
                CAST(f.cote + N' (' + ISNULL(m.libelle, N'sans gabarit') + N') : '
                     + ISNULL(fc.libelle, N'non conclue')
                     + CASE WHEN f.conclusion IS NOT NULL THEN N'. ' + f.conclusion ELSE N'' END
                     + CASE WHEN f.conclue_par IS NOT NULL THEN N' [' + f.conclue_par + N', ' + CONVERT(NVARCHAR (16), f.conclue_le, 120) + N']' ELSE N'' END
                     AS NVARCHAR (MAX)), NCHAR(10)) WITHIN GROUP (ORDER BY f.cote)
            FROM dbo.feuille_travail f
            LEFT JOIN dbo.modele_feuille m ON m.code = f.modele_code
            LEFT JOIN dbo.ref_forme_conclusion fc ON fc.code = f.forme_conclusion
            WHERE f.entite = @entite AND f.arrete = @arrete AND f.cycle = @cycle AND f.cote NOT LIKE 'Q-%');
END;

GO

