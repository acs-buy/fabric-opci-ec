-- C15 : une contrepartie sans reference rattachee. ATTENDU zero.
CREATE   VIEW dbo.v_controle_contrepartie_sans_reference AS
SELECT compte_estimation, compte_contrepartie, article
FROM dbo.ref_contrepartie_estimation WHERE reference_id IS NULL;

GO

