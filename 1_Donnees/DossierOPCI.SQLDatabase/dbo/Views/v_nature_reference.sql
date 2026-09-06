
-- --- 8 : les vues de lecture ----------------------------------------
-- La nature d'actif et sa reference complete, telle qu'un rapport doit
-- l'ecrire. Un intitule change dans dbo.ref_norme change cette colonne.
CREATE   VIEW dbo.v_nature_reference AS
SELECT n.nature, n.libelle AS nature_libelle, n.methode,
       CAST(n.expertise_requise AS BIT) AS valeur_externe_attendue,
       r.norme, r.reference, r.intitule AS reference_intitule,
       r.citation_courte, r.citation, r.lu_sur_piece, r.page_piece,
       r.norme_libelle, r.norme_libelle_complet, r.date_application,
       r.norme_en_vigueur
FROM dbo.ref_nature_actif n
LEFT JOIN dbo.v_reference r ON r.id = n.reference_id;

GO

