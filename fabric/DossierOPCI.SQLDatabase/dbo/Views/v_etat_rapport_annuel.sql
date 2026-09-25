
-- L'etat du rapport annuel : quel drapeau est leve, quelle piece est
-- rattachee, et le delai de 75 jours de l'article R. 214-125 du CMF.
CREATE   VIEW dbo.v_etat_rapport_annuel AS
SELECT ra.entite, ra.arrete, ra.exercice, ra.arrete_au,
       CAST(ra.rapport_gestion AS BIT)     AS rapport_gestion,
       CAST(ra.documents_synthese AS BIT)  AS documents_synthese,
       CAST(ra.certification_cac AS BIT)   AS certification_cac,
       CAST(ra.rapport_conseil_fpi AS BIT) AS rapport_conseil_fpi,
       CAST(ra.changements_substantiels AS BIT) AS changements_substantiels,
       ps.nom_fichier                      AS piece_synthese,
       pc.nom_fichier                      AS piece_certification,
       -- Le delai de mise a disposition au commissaire aux comptes.
       DATEADD(DAY, 75, ra.arrete_au)      AS echeance_75_jours,
       CAST(CASE WHEN CAST(SYSUTCDATETIME() AS DATE)
                      > DATEADD(DAY, 75, ra.arrete_au)
                 THEN 1 ELSE 0 END AS BIT) AS delai_depasse,
       N'CMF, art. R. 214-125 : la mise a la disposition du commissaire aux comptes des comptes annuels et du rapport de gestion mentionnes a l''article L. 214-50 s''effectue dans un delai de soixante-quinze jours suivant la cloture de l''exercice. Lu sur piece le 04/09/2026.'
                                           AS source_du_delai,
       ra.prepare_par, ra.prepare_le
FROM dbo.rapport_annuel ra
LEFT JOIN dbo.piece ps ON ps.id = ra.piece_synthese_id
LEFT JOIN dbo.piece pc ON pc.id = ra.piece_certification_id;

GO

