
-- --- 3 : les 3 controles avant contrainte. ATTENDU : zero ligne chacun -
-- 3a : un arrete employe quelque part et absent de la dimension. Une
-- ligne ici fera echouer la cle etrangere de sa table.
CREATE   VIEW dbo.v_controle_arrete_hors_dimension AS
WITH tous AS (
    SELECT 'arrete_mission' AS src, entite, arrete FROM dbo.arrete_mission
    UNION ALL SELECT 'detention', entite_mere, arrete FROM dbo.detention
    UNION ALL SELECT 'lot_ecritures', entite, arrete FROM dbo.lot_ecritures
    UNION ALL SELECT 'parts_en_circulation', entite, arrete FROM dbo.parts_en_circulation
    UNION ALL SELECT 'feuille_travail', entite, arrete FROM dbo.feuille_travail
    UNION ALL SELECT 'import_fec', entite, arrete FROM dbo.import_fec
    UNION ALL SELECT 'export_fec', entite, arrete FROM dbo.export_fec
    UNION ALL SELECT 'journal_refus', entite, arrete FROM dbo.journal_refus
    UNION ALL SELECT 'ref_croisee', entite, arrete FROM dbo.ref_croisee
    UNION ALL SELECT 'attestation', entite, arrete FROM dbo.attestation
    UNION ALL SELECT 'derogation', entite, arrete FROM dbo.derogation
    UNION ALL SELECT 'dip', entite, arrete FROM dbo.dip
    UNION ALL SELECT 'ecriture_brouillon', entite, arrete FROM dbo.ecriture_brouillon
    UNION ALL SELECT 'intention_ecriture', entite, arrete FROM dbo.intention_ecriture
    UNION ALL SELECT 'maintien_mission', entite, arrete_conclu FROM dbo.maintien_mission
    UNION ALL SELECT 'piece_rattachement', entite, arrete FROM dbo.piece_rattachement
    UNION ALL SELECT 'publication_vl', entite, arrete FROM dbo.publication_vl
    UNION ALL SELECT 'rapport_annuel', entite, arrete FROM dbo.rapport_annuel
)
SELECT DISTINCT t.src AS table_source, t.entite, t.arrete
FROM tous t
WHERE t.entite IS NOT NULL AND t.arrete IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete r
                  WHERE r.entite = t.entite AND r.arrete = t.arrete);

GO

