
-- C49 : une ligne de referentiel sans date d'effet, sur les 2 tables qui
-- la portent. ATTENDU zero.
CREATE   VIEW dbo.v_controle_sans_date_effet AS
SELECT 'ref_question' AS table_source, reference AS cle
FROM dbo.ref_question WHERE en_vigueur_depuis IS NULL
UNION ALL
SELECT 'ref_piece_attendue', CAST(id AS VARCHAR (30))
FROM dbo.ref_piece_attendue WHERE en_vigueur_depuis IS NULL;

GO

