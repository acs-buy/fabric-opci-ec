
-- Le message d'un obstacle en ecart de la derniere version (contrat, 4.3), NULL sans obstacle en ecart : pour C333_3_AN,
-- le rapprochement du 333-3 au bilan, colonne par colonne en ecart.
CREATE   FUNCTION dbo.fn_ann_message_obstacle (@entite VARCHAR (20), @arrete VARCHAR (20))
RETURNS NVARCHAR (2000)
AS
BEGIN
    DECLARE @m NVARCHAR (2000) = (
        SELECT STRING_AGG(CAST(N'exercice ' + CASE WHEN k.cle = N'colonne 2' THEN N'N-1' ELSE N'N' END
                               + N', actif net en fin d''exercice ' + FORMAT(c.valeur_numerique + k.ecart, 'N2', 'fr-FR')
                               + N', capitaux propres ' + FORMAT(c.valeur_numerique, 'N2', 'fr-FR')
                               + N', écart ' + FORMAT(k.ecart, 'N2', 'fr-FR') AS NVARCHAR (MAX)), N' ; ') WITHIN GROUP (ORDER BY k.cle)
        FROM dbo.controle_annexe k
        JOIN dbo.v_annexe_version v ON v.entite = k.entite AND v.arrete = k.arrete
        JOIN dbo.cellule_annexe c ON c.entite = k.entite AND c.arrete = k.arrete AND c.version = v.derniere_version
                                 AND c.article = '333-3' AND c.ligne = N'AN_FIN' AND c.colonne = CASE WHEN k.cle = N'colonne 2' THEN 2 ELSE 1 END
        WHERE k.entite = @entite AND k.arrete = @arrete AND k.controle = 'C333_3_AN' AND k.effet = 'obstacle' AND ABS(k.ecart) > 0.005);
    IF @m IS NULL RETURN NULL;
    RETURN N'le tableau 333-3 ne se rapproche pas du bilan : ' + @m + N' ; l''article 333-3 intitule le tableau « actif net (= capitaux propres) ».';
END;

GO

