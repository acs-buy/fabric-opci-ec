
-- 8 lignes par arrete du segment (est_reouvrable ou demande_en_attente), ce que l'accord ferait, compte en base.
CREATE   VIEW dbo.v_ecran_reouverture_effets AS
SELECT a.entite, a.arrete, l.ordre, a.entite + '|' + a.arrete + '|' + CAST(l.ordre AS VARCHAR (2)) AS cle_ecran,
       l.quoi AS [Ce que touche la réouverture], l.aujourdhui AS [Aujourd'hui], l.apres AS [Après la réouverture]
FROM dbo.v_ecran_arretes a
OUTER APPLY (SELECT TOP (1) v.decide_le, v.decide_par FROM dbo.visa v
             WHERE v.nature = 'CLOTURE' AND v.decision = 'VISE' AND v.entite = a.entite AND v.arrete = a.arrete ORDER BY v.id DESC) cv
OUTER APPLY (SELECT COUNT(*) AS n FROM dbo.document_produit d WHERE d.entite = a.entite AND d.arrete = a.arrete AND d.perime_le IS NULL) dv
OUTER APPLY (SELECT COUNT(*) AS n FROM dbo.copie_livrable k JOIN dbo.document_produit d ON d.id = k.document_id
             WHERE d.entite = a.entite AND d.arrete = a.arrete AND d.perime_le IS NULL AND k.perimee_le IS NULL) cp
OUTER APPLY (SELECT TOP (1) t.arretee_le FROM dbo.attestation t WHERE t.entite = a.entite AND t.arrete = a.arrete) att
OUTER APPLY (SELECT MAX(p.publiee_le) AS le FROM dbo.publication_client p WHERE p.entite = a.entite AND p.arrete = a.arrete AND p.etat = 'PUBLIEE') pub
OUTER APPLY (SELECT TOP (1) dv2.verrouille, dv2.verrouille_le FROM dbo.dossier_verrou dv2 WHERE dv2.entite = a.entite AND dv2.arrete = a.arrete) vr
OUTER APPLY (SELECT dbo.fn_revue_visee(a.entite, a.arrete) AS visee) rv
CROSS APPLY (VALUES
    (1, N'Visa de clôture',
        CASE WHEN cv.decide_le IS NOT NULL THEN N'visé le ' + CONVERT(NVARCHAR (10), cv.decide_le, 103) + N' par ' + dbo.fn_nom_personne_ecran(a.entite, cv.decide_par) ELSE N'aucun visa' END,
        N'renvoyé ; le visa d''origine demeure'),
    (2, N'Statut de l''arrêté', CASE WHEN a.est_clos = 1 THEN N'Clos' ELSE N'Ouvert' END, N'Ouvert'),
    (3, N'Documents produits',
        CASE WHEN dv.n = 0 THEN N'aucun en vigueur' ELSE CAST(dv.n AS NVARCHAR (10)) + N' en vigueur' END,
        CASE WHEN dv.n = 0 THEN N'aucun à périmer' WHEN dv.n = 1 THEN N'1 périmé, avec le motif' ELSE CAST(dv.n AS NVARCHAR (10)) + N' périmés, avec le motif' END),
    (4, N'Forme de l''attestation',
        CASE WHEN att.arretee_le IS NOT NULL THEN N'arrêtée le ' + CONVERT(NVARCHAR (10), att.arretee_le, 103) ELSE N'non arrêtée' END,
        CASE WHEN att.arretee_le IS NOT NULL THEN N'à arrêter de nouveau' ELSE N'inchangée' END),
    (5, N'Rapport client',
        CASE WHEN pub.le IS NOT NULL THEN N'publié le ' + CONVERT(NVARCHAR (10), pub.le, 103) ELSE N'non publié' END,
        CASE WHEN pub.le IS NOT NULL THEN N'publication du ' + CONVERT(NVARCHAR (10), pub.le, 103) + N' maintenue jusqu''à la suivante' ELSE N'inchangé' END),
    (6, N'Verrou et revue',
        CASE WHEN vr.verrouille = 1 THEN N'verrouillé le ' + CONVERT(NVARCHAR (10), vr.verrouille_le, 103) ELSE N'non verrouillé' END
            + CASE WHEN rv.visee = 1 THEN N' ; revue visée' ELSE N' ; revue non visée' END,
        CASE WHEN vr.verrouille = 1 AND rv.visee = 1 THEN N'verrou levé ; revue renvoyée'
             WHEN vr.verrouille = 1 THEN N'verrou levé'
             WHEN rv.visee = 1 THEN N'revue renvoyée'
             ELSE N'inchangés' END),
    (7, N'Maintien, écritures, lots', N'en l''état', N'inchangés'),
    (8, N'Copies chez le client',
        CASE WHEN cp.n = 0 THEN N'aucune copie' WHEN cp.n = 1 THEN N'1 copie au site du véhicule' ELSE CAST(cp.n AS NVARCHAR (10)) + N' copies au site du véhicule' END,
        CASE WHEN cp.n = 0 THEN N'aucune copie chez le client' WHEN cp.n = 1 THEN N'1 copie chez le client marquée périmée'
             ELSE CAST(cp.n AS NVARCHAR (10)) + N' copies chez le client marquées périmées' END)
) l (ordre, quoi, aujourdhui, apres)
WHERE a.est_reouvrable = 1 OR a.demande_en_attente = 1;

GO

