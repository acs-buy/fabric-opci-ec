
-- ------------------------------------------------------------------------------------------------- 2.6 : les 3 vues
CREATE   VIEW dbo.v_ecran_arretes AS
SELECT r.entite, r.arrete,
       dbo.fn_date_ecran(r.arrete) AS [Arrêté],
       CAST(CASE r.type_arrete WHEN 'ANNUEL' THEN N'Annuel' WHEN 'SEMESTRIEL' THEN N'Semestriel' ELSE N'Trimestriel' END AS NVARCHAR (20)) AS [Type],
       CONVERT(NVARCHAR (10), am.ouvert_le, 103) AS [Ouvert le],
       CAST(CASE mt.code WHEN 'APPROUVE' THEN N'Visé' WHEN 'OUVERT' THEN N'Soumis au visa' WHEN 'REFUSE' THEN N'Refusé' WHEN 'A_FAIRE' THEN N'À faire' END AS NVARCHAR (20))
           AS [Maintien de la mission],
       CAST(CASE WHEN am.id IS NULL THEN 'PLANIFIE' WHEN dbo.fn_valide_pour_client(r.entite, r.arrete) = 1 THEN 'CLOS' ELSE 'OUVERT' END AS VARCHAR (10)) AS statut,
       CAST(CASE WHEN am.id IS NOT NULL AND dbo.fn_valide_pour_client(r.entite, r.arrete) = 1 THEN 1 ELSE 0 END AS BIT) AS est_clos,
       CAST(CASE WHEN am.id IS NOT NULL AND dbo.fn_valide_pour_client(r.entite, r.arrete) = 0 THEN 1 ELSE 0 END AS BIT) AS est_ouvert,
       CAST(CASE WHEN nr.motif IS NULL THEN 1 ELSE 0 END AS BIT) AS est_reouvrable,
       nr.motif AS motif_non_reouvrable,
       CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.demande_reouverture q WHERE q.entite = r.entite AND q.arrete = r.arrete AND q.etat = 'EN_ATTENTE')
                 THEN 1 ELSE 0 END AS BIT) AS demande_en_attente,
       mt.code AS maintien_code,
       e.periodicite_vl,
       r.entite + '|' + r.arrete AS cle_ecran
FROM dbo.ref_arrete r
JOIN dbo.ref_entite e ON e.code = r.entite
LEFT JOIN dbo.arrete_mission am ON am.entite = r.entite AND am.arrete = r.arrete
OUTER APPLY (SELECT TOP (1) CASE WHEN m.a_faire = 1 THEN 'A_FAIRE' ELSE m.statut_code END AS code
             FROM dbo.v_ecran_maintiens m WHERE m.entite = r.entite AND m.exercice = r.exercice) mt
OUTER APPLY (SELECT dbo.fn_motif_non_reouvrable(r.entite, r.arrete) AS motif) nr
WHERE r.est_arrete_client = 1;

GO

