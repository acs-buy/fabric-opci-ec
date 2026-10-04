
-- 6. « Les dividendes à verser : l'obligation minimale, article L. 214-69 du CMF », et le dividende par part. A un
-- arrete non annuel, l'exercice lu est le dernier exercice clos (exercice_distribution), dit par exercice_lu et lecture.
CREATE   VIEW dbo.v_dip_rubrique_6 AS
SELECT g.entite, g.arrete, g.cle_arrete, g.exercice_distribution AS exercice_lu,
       o.ordre, o.categorie, o.base_calcul, o.taux, o.obligation,
       dpp.distribution_par_part,
       CAST(CASE WHEN g.type_arrete = 'ANNUEL' THEN N'obligation et dividende de l''exercice de l''arrêté'
                 ELSE N'obligation et dividende par part du dernier exercice clos, ' + ISNULL(g.exercice_distribution, N'à remplir')
                      + N' ; la date de versement n''est pas en base' END AS NVARCHAR (200)) AS lecture,
       CAST(CASE WHEN o.categorie IS NULL THEN N'à remplir' END AS NVARCHAR (20)) AS etat
FROM dbo.v_dip_arrete g
LEFT JOIN dbo.v_client_obligation_distribution o ON o.entite = g.entite AND o.arrete = g.exercice_distribution
LEFT JOIN dbo.ref_arrete ex ON ex.entite = g.entite AND ex.arrete = g.exercice_distribution
LEFT JOIN dbo.v_distribution_par_part dpp ON dpp.entite = g.entite AND dpp.date_valeur = ex.date_arrete;

GO

