
-- --- 6 : le controle. ATTENDU : 13 correspondances, dont 3 qui
--          changent de classe, 0 correspondance sans fondement -----
CREATE   VIEW dbo.v_controle_correspondance_sans_fondement AS
SELECT norme_source, compte_source, compte_modele
FROM dbo.ref_correspondance_plan WHERE reference_id IS NULL;

GO

