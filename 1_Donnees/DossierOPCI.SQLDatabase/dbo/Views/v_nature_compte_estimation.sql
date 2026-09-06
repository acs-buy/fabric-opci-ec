
-- --- 7 : la correspondance nature vers compte, sur le referentiel ---
CREATE   VIEW dbo.v_nature_compte_estimation AS
SELECT DISTINCT
       a.nature, n.libelle AS nature_libelle,
       re.citation_courte                             AS reference_evaluation,
       re.norme                                       AS norme_evaluation,
       a.poste_bilan,
       cp.libelle                                     AS poste_libelle,
       dbo.fn_compte_difference_estimation(a.poste_bilan)
                                                      AS compte_difference,
       cd.libelle                                     AS compte_difference_libelle,
       ce.compte_contrepartie                         AS compte_contrepartie,
       cc.libelle                                     AS compte_contrepartie_libelle,
       rc.citation_courte                             AS reference_contrepartie
FROM dbo.actif a
JOIN dbo.ref_nature_actif n ON n.nature = a.nature
LEFT JOIN dbo.v_reference re ON re.id = n.reference_id
LEFT JOIN dbo.ref_compte cp ON cp.compte = a.poste_bilan
LEFT JOIN dbo.ref_compte cd
       ON cd.compte = dbo.fn_compte_difference_estimation(a.poste_bilan)
LEFT JOIN dbo.ref_contrepartie_estimation ce
       ON ce.compte_estimation = dbo.fn_compte_difference_estimation(a.poste_bilan)
LEFT JOIN dbo.v_reference rc ON rc.id = ce.reference_id
LEFT JOIN dbo.ref_compte cc ON cc.compte = ce.compte_contrepartie;

GO

