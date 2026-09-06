
-- --- 7 : les controles -----------------------------------------------
-- C11 : une reference qui renvoie a une norme abrogee. ATTENDU zero : la
-- solution ne cite aucun texte abroge.
CREATE   VIEW dbo.v_controle_reference_abrogee AS
SELECT id, norme, reference, intitule, abroge_par
FROM dbo.v_reference WHERE norme_en_vigueur = 0;

GO

