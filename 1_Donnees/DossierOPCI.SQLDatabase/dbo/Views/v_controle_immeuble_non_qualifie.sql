
-- --- 9 : les controles ----------------------------------------------
-- C74 : un immeuble non qualifie au regard des articles R. 214-81 et
-- R. 214-82. Le controle ne trouve rien une fois le jeu qualifie, mais
-- il tombera le jour ou un immeuble entrera sans qualification.
CREATE   VIEW dbo.v_controle_immeuble_non_qualifie AS
SELECT c.code_actif, c.entite_detentrice, c.adresse, c.lecture
FROM dbo.v_conformite_immeuble c
WHERE c.conforme = 0;

GO

