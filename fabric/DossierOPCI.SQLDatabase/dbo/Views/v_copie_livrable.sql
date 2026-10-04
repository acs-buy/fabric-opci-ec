
CREATE   VIEW dbo.v_copie_livrable AS
SELECT v.entite, v.arrete, v.document_id, v.livrable, v.version, v.format, v.fichier, v.web_url,
       c.web_url AS web_url_copie, c.copie_par, c.copie_le,
       CAST(CASE WHEN c.id IS NULL THEN N'copie à faire' ELSE N'copié' END AS NVARCHAR (20)) AS etat
FROM dbo.v_livrables_a_valider v
JOIN dbo.v_visa_cloture_courant d ON d.entite = v.entite AND d.arrete = v.arrete AND d.decision = 'VISE'
OUTER APPLY (SELECT TOP (1) * FROM dbo.copie_livrable k WHERE k.document_id = v.document_id ORDER BY k.copie_le DESC) c
WHERE v.document_id IS NOT NULL;

GO

