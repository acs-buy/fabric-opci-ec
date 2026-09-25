
-- --- 6 : les comptes du fichier qui ne sont pas encore rattaches
-- ATTENDU apres un import : aucune ligne, sinon le chargement est bloque.
CREATE   VIEW dbo.v_comptes_non_rattaches AS
SELECT DISTINCT s.import_id, s.entite, s.compte_num, s.compte_lib
FROM dbo.stg_fec s
LEFT JOIN dbo.ref_compte_entite r ON r.entite = s.entite
                                 AND r.compte_entite = s.compte_num
WHERE s.recevable = 1 AND r.compte_entite IS NULL;

GO

