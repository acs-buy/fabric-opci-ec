
-- --- 4 : les controles -----------------------------------------------
-- C5 : un actif de classe 2 ou 3 dont le compte de difference ne se
-- derive pas. ATTENDU zero.
CREATE   VIEW dbo.v_controle_compte_estimation_absent AS
SELECT a.code, a.entite_detentrice, a.nature, a.poste_bilan
FROM dbo.actif a
WHERE dbo.fn_compte_difference_estimation(a.poste_bilan) IS NULL;

GO

