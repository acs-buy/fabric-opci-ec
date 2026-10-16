
CREATE   VIEW dbo.v_ecran_demandes_reouverture AS
SELECT q.id, q.entite, q.arrete, q.etat, q.demande_par, q.decide_par, q.visa_id, q.demande_le, q.entite + '|' + CAST(q.id AS VARCHAR (10)) AS cle_ecran,
       dbo.fn_date_ecran(q.arrete) AS [Arrêté],
       dbo.fn_nom_personne_ecran(q.entite, q.demande_par) AS [Demandée par],
       CONVERT(NVARCHAR (10), q.demande_le, 103) AS [Demandée le],
       q.motif AS [Motif de la demande],
       CAST(CASE q.etat WHEN 'EN_ATTENTE' THEN N'En attente' WHEN 'ACCORDEE' THEN N'Accordée' ELSE N'Écartée' END AS NVARCHAR (20)) AS [État],
       CASE WHEN q.decide_par IS NOT NULL THEN dbo.fn_nom_personne_ecran(q.entite, q.decide_par) END AS [Décidée par],
       CONVERT(NVARCHAR (10), q.decide_le, 103) AS [Décidée le],
       q.motif_ecart AS [Motif de l'écart]
FROM dbo.demande_reouverture q;

GO

