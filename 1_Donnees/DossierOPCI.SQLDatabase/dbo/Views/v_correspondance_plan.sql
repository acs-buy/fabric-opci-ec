
-- --- 5 : la vue de lecture des correspondances ---------------------
CREATE   VIEW dbo.v_correspondance_plan AS
SELECT c.norme_source, n.libelle_court AS norme_libelle, c.compte_source,
       c.compte_modele, m.libelle AS compte_modele_libelle, c.motif,
       r.citation_courte AS fondement,
       CAST(CASE WHEN LEFT(c.compte_source, 1) <> LEFT(c.compte_modele, 1)
                 THEN 1 ELSE 0 END AS BIT) AS change_de_classe,
       CAST(CASE WHEN c.compte_source = c.compte_modele THEN 1 ELSE 0 END AS BIT)
           AS identite
FROM dbo.ref_correspondance_plan c
JOIN dbo.ref_norme n ON n.code = c.norme_source
LEFT JOIN dbo.ref_compte m ON m.compte = c.compte_modele
LEFT JOIN dbo.v_reference r ON r.id = c.reference_id;

GO

