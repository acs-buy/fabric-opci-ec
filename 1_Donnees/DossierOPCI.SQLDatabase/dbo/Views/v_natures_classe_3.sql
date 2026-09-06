
-- --- 6 : les natures de classe 3 et la nature exigeant une valeur
--         externe, refaites sur le referentiel ---------------------
CREATE   VIEW dbo.v_natures_classe_3 AS
SELECT n.nature, n.libelle, n.methode, r.norme, r.reference,
       r.citation_courte, r.intitule AS reference_intitule,
       r.lu_sur_piece, r.page_piece,
       CAST(n.expertise_requise AS BIT) AS valeur_externe_attendue
FROM dbo.ref_nature_actif n
LEFT JOIN dbo.v_reference r ON r.id = n.reference_id
WHERE n.nature IN ('ACTION_ASSIMILEE', 'OBLIGATION_ASSIMILEE', 'TITRE_CREANCE',
                   'PART_OPC', 'DEPOT', 'OPERATION_TEMPORAIRE',
                   'INSTRUMENT_TERME');

GO

