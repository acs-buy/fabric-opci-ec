
-- --- 4 : ce qui s'appuierait sur un texte abroge --------------------
-- C76 : une reference ABROGEE encore citee par un outil du dossier, que
-- ce soit une question de questionnaire, une ligne d'annexe ou un modele
-- d'ecriture. La vue ne juge pas : elle nomme, pour que la revue du
-- referentiel parte d'une liste et non d'une relecture.
CREATE   VIEW dbo.v_controle_appui_sur_texte_abroge AS
SELECT r.norme, r.reference, r.abroge_le, r.abroge_par,
       o.outil, o.identifiant,
       N'l''outil cite un texte abrogé le '
       + CONVERT(NVARCHAR (10), r.abroge_le, 103)
       + N' : reprendre son fondement'                AS lecture
FROM dbo.ref_reference r
CROSS APPLY (
    SELECT N'question' AS outil, CAST(q.id AS NVARCHAR (60)) AS identifiant
    FROM dbo.ref_question q
    WHERE q.reference_texte LIKE N'%' + r.reference + N'%'
    UNION ALL
    SELECT N'ligne d''annexe', CAST(l.code AS NVARCHAR (60))
    FROM dbo.ref_ligne_annexe l
    WHERE l.article LIKE N'%' + r.reference + N'%'
) AS o
WHERE r.abroge_le IS NOT NULL;

GO

