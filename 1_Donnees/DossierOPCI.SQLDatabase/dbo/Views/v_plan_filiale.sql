
-- --- 4 : la vue du plan de chaque filiale, pour lecture -------------
CREATE   VIEW dbo.v_plan_filiale AS
SELECT r.entite, r.compte_entite, r.libelle_entite, r.compte_modele,
       m.libelle AS libelle_modele, c.motif,
       CAST(CASE WHEN LEFT(r.compte_entite, 1) <> LEFT(r.compte_modele, 1)
                 THEN 1 ELSE 0 END AS BIT) AS change_de_classe
FROM dbo.ref_compte_entite r
JOIN dbo.detention d ON d.entite_fille = r.entite AND d.entite_mere = 'OMEGA-OPCI'
LEFT JOIN dbo.ref_compte m ON m.compte = r.compte_modele
LEFT JOIN dbo.ref_correspondance_plan c ON c.compte_source = r.compte_entite
                                       AND c.compte_modele = r.compte_modele
                                       AND c.norme_source = 'PCG';

GO

