
-- Les documents de l'annexe et leur version (contrat, 1.4) : un document produit sur une version anterieure, perime ou
-- non, et un document produit avant la regle unique (annexe_version NULL).
CREATE   VIEW dbo.v_annexe_document AS
SELECT p.id AS document_id, p.entite, p.arrete, p.livrable, p.version, p.annexe_version, v.derniere_version,
       CAST(CASE WHEN p.annexe_version IS NOT NULL AND p.annexe_version < v.derniere_version THEN 1 ELSE 0 END AS BIT) AS sur_version_anterieure,
       p.perime_le, p.perime_motif,
       CAST(CASE WHEN p.perime_le IS NOT NULL THEN N'périmé'
                 WHEN p.annexe_version IS NULL THEN N'produit avant la règle unique'
                 WHEN p.annexe_version < v.derniere_version
                 THEN N'produit sur la version ' + CAST(p.annexe_version AS NVARCHAR (10)) + N', dernière version ' + CAST(v.derniere_version AS NVARCHAR (10))
                 ELSE N'produit sur la dernière version' END AS NVARCHAR (120)) AS lecture
FROM dbo.document_produit p
LEFT JOIN dbo.v_annexe_version v ON v.entite = p.entite AND v.arrete = p.arrete
WHERE p.livrable IN ('COMPTES_ANNUELS', 'ATTESTATION');

GO

