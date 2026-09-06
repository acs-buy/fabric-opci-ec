
-- --- 9 : les controles ----------------------------------------------
-- C14 : une nature d'actif sans reference rattachee. ATTENDU zero.
CREATE   VIEW dbo.v_controle_nature_sans_reference AS
SELECT nature, libelle, article FROM dbo.ref_nature_actif
WHERE reference_id IS NULL;

GO

