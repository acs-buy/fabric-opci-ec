
-- Le decompte par article de la derniere version (contrat, 4.1), une ligne par article qui porte une cellule.
CREATE   VIEW dbo.v_cellules_a_remplir AS
SELECT c.entite, c.arrete, c.article,
       ISNULL(t.libelle, CASE c.article WHEN '311-1' THEN N'Devise de comptabilité' END) AS tableau,
       CAST(ISNULL(t.indicatif, 0) AS BIT) AS indicatif,
       SUM(CAST(c.comptee AS INT)) AS cellules_a_remplir,
       SUM(CASE WHEN c.etat <> 'SANS_OBJET' THEN 1 ELSE 0 END) AS cellules,
       CAST(CASE WHEN SUM(CAST(c.comptee AS INT)) = 0 AND SUM(CASE WHEN c.etat = 'EN_ATTENTE' THEN 1 ELSE 0 END) = 0 THEN N'complet'
                 WHEN SUM(CASE WHEN c.comptee = 1 AND c.obligation = 'IMPOSEE' THEN 1 ELSE 0 END) > 0 OR MAX(CAST(c.attend_exigee AS INT)) = 1
                 THEN N'incomplet, informations exigées à remplir : le Word les imprime vides'
                 ELSE N'incomplet, informations conditionnelles à remplir : le Word les imprime vides' END AS NVARCHAR (126)) AS lecture,
       SUM(CASE WHEN c.comptee = 1 AND c.obligation = 'IMPOSEE' THEN 1 ELSE 0 END) AS imposees,
       SUM(CASE WHEN c.etat = 'EN_ATTENTE' THEN 1 ELSE 0 END) AS en_attente
FROM dbo.v_annexe_cellule c
LEFT JOIN dbo.ref_tableau_annexe t ON t.article = c.article
GROUP BY c.entite, c.arrete, c.article, t.libelle, t.indicatif;

GO

