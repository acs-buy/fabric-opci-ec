
-- ------------------------------------------------------------------------------------------------- 2.5, point 5 : le controle
-- Une ligne par ecart. Borne : les renvois de cloture decides a partir du 08/10/2026, jour de la pose ; le renvoi n° 131
-- du 13/09/2026, anterieur, n'y figure pas.
CREATE   VIEW dbo.v_controle_renvoi_sans_demande AS
WITH renvoi AS (
    SELECT v.id, v.entite, v.arrete, v.propose_par, v.decide_par, v.decide_le, v.motif
    FROM dbo.visa v WHERE v.nature = 'CLOTURE' AND v.decision = 'RENVOYE' AND v.decide_le >= '2026-10-08'
)
SELECT 'a' AS cas, r.entite, r.arrete, CAST(r.id AS NVARCHAR (40)) AS objet,
       N'renvoi de clôture qu''aucune demande accordée ne désigne' AS lecture
FROM renvoi r WHERE NOT EXISTS (SELECT 1 FROM dbo.demande_reouverture q WHERE q.visa_id = r.id AND q.etat = 'ACCORDEE')
UNION ALL
SELECT 'b', q.entite, q.arrete, CAST(q.id AS NVARCHAR (40)),
       N'demande accordée dont le visa n''est pas un renvoi de clôture de son arrêté, proposé par son auteur, décidé par son décideur, au motif de la demande'
FROM dbo.demande_reouverture q LEFT JOIN dbo.visa v ON v.id = q.visa_id
WHERE q.etat = 'ACCORDEE'
  AND (v.id IS NULL OR v.nature <> 'CLOTURE' OR v.decision <> 'RENVOYE' OR v.entite <> q.entite OR v.arrete <> q.arrete
       OR v.propose_par <> q.demande_par OR v.decide_par <> q.decide_par OR ISNULL(v.motif, N'') <> N'Réouverture : ' + q.motif)
UNION ALL
SELECT 'c', d.entite, d.arrete, CAST(d.id AS NVARCHAR (40)), N'document produit avant un renvoi de clôture et toujours en vigueur'
FROM dbo.document_produit d
WHERE d.perime_le IS NULL AND EXISTS (SELECT 1 FROM renvoi r WHERE r.entite = d.entite AND r.arrete = d.arrete AND d.produit_le < r.decide_le)
UNION ALL
SELECT 'd', a.entite, a.arrete, CAST(a.id AS NVARCHAR (40)), N'attestation arrêtée ou produite avant le dernier renvoi de clôture'
FROM dbo.attestation a
CROSS APPLY (SELECT MAX(r.decide_le) AS le FROM renvoi r WHERE r.entite = a.entite AND r.arrete = a.arrete) r
WHERE r.le IS NOT NULL AND (a.arretee_le < r.le OR a.produit_le < r.le)
UNION ALL
SELECT 'e', q.entite, q.arrete, CAST(q.id AS NVARCHAR (40)), N'demande en attente sur un arrêté qui n''est pas validé pour le client'
FROM dbo.demande_reouverture q
WHERE q.etat = 'EN_ATTENTE' AND dbo.fn_valide_pour_client(q.entite, q.arrete) = 0;

GO

