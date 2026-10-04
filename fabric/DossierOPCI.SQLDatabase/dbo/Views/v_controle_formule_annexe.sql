
-- Le controle : une formule de codes qui cite un code absent de son article. ATTENDU zero.
CREATE   VIEW dbo.v_controle_formule_annexe AS
SELECT f.article, f.code, f.code_composante AS terme_inconnu
FROM dbo.v_ligne_annexe_formule f
WHERE NOT EXISTS (SELECT 1 FROM dbo.ref_ligne_annexe l WHERE l.article = f.article AND l.code = f.code_composante);

GO

