
-- 7 B : les copies chez le client, avec leur marque. Branche 1 inchangee (arretes au visa de cloture courant VISE),
-- plus perimee_le et etat_copie ; branche 2 : les copies marquees perimees, que la branche 1 ne rend plus apres
-- l'accord (l'arrete n'y est plus valide, et leur document n'est plus le document courant).
CREATE   VIEW dbo.v_copie_livrable AS
SELECT v.entite, v.arrete, v.document_id, v.livrable, v.version, v.format, v.fichier, v.web_url,
       c.web_url AS web_url_copie, c.copie_par, c.copie_le,
       CAST(CASE WHEN c.id IS NULL THEN N'copie à faire' ELSE N'copié' END AS NVARCHAR (20)) AS etat,
       c.perimee_le,
       CAST(CASE WHEN c.id IS NULL THEN NULL WHEN c.perimee_le IS NULL THEN N'en vigueur'
                 ELSE N'périmée le ' + CONVERT(NVARCHAR (10), c.perimee_le, 103) END AS NVARCHAR (30)) AS etat_copie
FROM dbo.v_livrables_a_valider v
JOIN dbo.v_visa_cloture_courant d ON d.entite = v.entite AND d.arrete = v.arrete AND d.decision = 'VISE'
OUTER APPLY (SELECT TOP (1) * FROM dbo.copie_livrable k WHERE k.document_id = v.document_id ORDER BY k.copie_le DESC) c
WHERE v.document_id IS NOT NULL
UNION ALL
SELECT p.entite, p.arrete, p.id, p.livrable, p.version, p.format, p.fichier, p.web_url,
       k.web_url, k.copie_par, k.copie_le, CAST(N'copié' AS NVARCHAR (20)), k.perimee_le,
       CAST(N'périmée le ' + CONVERT(NVARCHAR (10), k.perimee_le, 103) AS NVARCHAR (30))
FROM dbo.copie_livrable k
JOIN dbo.document_produit p ON p.id = k.document_id
WHERE k.perimee_le IS NOT NULL;

GO

