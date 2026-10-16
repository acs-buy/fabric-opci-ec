
CREATE   VIEW dbo.v_annexe_article AS
SELECT v.entite, v.arrete, t.article, t.libelle AS tableau, t.ordre, t.principe, t.texte_principe,
       ISNULL(c.cellules, 0) AS cellules, ISNULL(c.cellules_a_remplir, 0) AS cellules_a_remplir
FROM dbo.v_annexe_version v
CROSS JOIN dbo.ref_tableau_annexe t
LEFT JOIN dbo.v_cellules_a_remplir c ON c.entite = v.entite AND c.arrete = v.arrete AND c.article = t.article;

GO

