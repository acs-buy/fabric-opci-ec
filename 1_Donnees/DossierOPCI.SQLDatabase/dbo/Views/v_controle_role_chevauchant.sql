
-- --- 7 : les 2 controles. ATTENDU : zero ligne chacun -----------------
-- 7a : un chevauchement que le declencheur aurait laisse passer.
CREATE   VIEW dbo.v_controle_role_chevauchant AS
SELECT a.entite, a.role, a.personne AS personne_1, a.du AS du_1, a.au AS au_1,
       b.personne AS personne_2, b.du AS du_2, b.au AS au_2
FROM dbo.role_mission a
JOIN dbo.role_mission b
  ON b.entite = a.entite AND b.role = a.role AND b.id < a.id
 AND a.du < COALESCE(b.au, '9999-12-31')
 AND b.du < COALESCE(a.au, '9999-12-31');

GO

