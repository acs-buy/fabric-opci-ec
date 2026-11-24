-- --- 7. v_ecran_demandes_reouverture ---------------------------------------------------------------------
-- --- 2 ---------------------------------------------------------------------------------------------
-- : demande_le, [Demandée le] et [Décidée le] a l'heure de Paris, heure d'ete comprise.
-- : nature_code et [Nature] (« Réouverture » ou « Déverrouillage »), en dernier ; les autres colonnes inchangees.
CREATE   VIEW dbo.v_ecran_demandes_reouverture AS
SELECT q.id, q.entite, q.arrete, q.etat, q.demande_par, q.decide_par, q.visa_id, h.demande_le, q.entite + '|' + CAST(q.id AS VARCHAR (10)) AS cle_ecran,
       dbo.fn_date_ecran(q.arrete) AS [Arrêté],
       dbo.fn_nom_personne_ecran(q.entite, q.demande_par) AS [Demandée par],
       CONVERT(NVARCHAR (10), h.demande_le, 103) AS [Demandée le],
       q.motif AS [Motif de la demande],
       CAST(CASE q.etat WHEN 'EN_ATTENTE' THEN N'En attente' WHEN 'ACCORDEE' THEN N'Accordée' ELSE N'Écartée' END AS NVARCHAR (20)) AS [État],
       CASE WHEN q.decide_par IS NOT NULL THEN dbo.fn_nom_personne_ecran(q.entite, q.decide_par) END AS [Décidée par],
       CONVERT(NVARCHAR (10), h.decide_le, 103) AS [Décidée le],
       q.motif_ecart AS [Motif de l'écart],
       q.nature AS nature_code,
       CAST(CASE q.nature WHEN 'DEVERROUILLAGE' THEN N'Déverrouillage' ELSE N'Réouverture' END AS NVARCHAR (20)) AS [Nature]
FROM dbo.demande_reouverture q
CROSS APPLY (SELECT ISNULL(CAST(q.demande_le AT TIME ZONE 'UTC' AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (3)), q.demande_le) AS demande_le, CAST(q.decide_le AT TIME ZONE 'UTC' AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (3)) AS decide_le) h;

GO

