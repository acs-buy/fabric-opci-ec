
-- C61 : un fichier depose produit hors de la fenetre : a sa production, la derniere decision REVUE n'etait pas VISE, ou
-- la derniere decision CLOTURE etait VISE. ATTENDU zero. La ligne antérieure, au chemin du coffre, est hors de son champ.
CREATE   VIEW dbo.v_controle_document_hors_cloture AS
SELECT d.entite, d.arrete, d.livrable, d.version, d.format, d.fichier, d.produit_le,
       CAST(CASE WHEN rv.decision IS NULL OR rv.decision <> 'VISE' THEN N'produit sans revue visée'
                 ELSE N'produit après la validation pour le client' END AS NVARCHAR (60)) AS lecture
FROM dbo.document_produit d
OUTER APPLY (SELECT TOP (1) v.decision FROM dbo.visa v WHERE v.nature = 'REVUE' AND v.objet_ref = d.entite + '|' + d.arrete
             AND v.decide_le <= d.produit_le ORDER BY v.decide_le DESC, v.id DESC) rv
OUTER APPLY (SELECT TOP (1) v.decision FROM dbo.visa v WHERE v.nature = 'CLOTURE' AND v.entite = d.entite AND v.arrete = d.arrete
             AND v.decide_le <= d.produit_le ORDER BY v.decide_le DESC, v.id DESC) cl
WHERE d.web_url IS NOT NULL
  AND (rv.decision IS NULL OR rv.decision <> 'VISE' OR cl.decision = 'VISE');

GO

