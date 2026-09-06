
-- C64 : une ligne de tableau calculable dont aucune racine ni formule
-- ne dit d'ou vient le montant. ATTENDU zero.
CREATE   VIEW dbo.v_controle_ligne_annexe_sans_source AS
SELECT article, code, LEFT(libelle, 70) AS libelle, type_ligne
FROM dbo.ref_ligne_annexe
WHERE type_ligne = 'CALCUL' AND racines IS NULL AND formule IS NULL;

GO

