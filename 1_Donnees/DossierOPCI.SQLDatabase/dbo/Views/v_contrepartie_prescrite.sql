
-- --- 4 : la vue de lecture, pour l'ecran et pour la preuve -------------
CREATE   VIEW dbo.v_contrepartie_prescrite AS
SELECT r.compte_estimation,
       COALESCE(ce.libelle, r.compte_estimation)   AS estimation_libelle,
       r.compte_contrepartie,
       COALESCE(cc.libelle, r.compte_contrepartie) AS contrepartie_libelle,
       r.article, r.motif,
       ce.source_article                            AS provenance_estimation
FROM dbo.ref_contrepartie_estimation r
LEFT JOIN dbo.ref_compte ce ON ce.compte = r.compte_estimation
LEFT JOIN dbo.ref_compte cc ON cc.compte = r.compte_contrepartie;

GO

