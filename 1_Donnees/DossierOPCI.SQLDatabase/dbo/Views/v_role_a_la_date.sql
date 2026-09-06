
-- --- 4 : le role en vigueur a une date --------------------------------
CREATE   VIEW dbo.v_role_a_la_date AS
SELECT r.entite, r.role, r.personne, r.du, r.au,
       f.libelle AS role_libelle, f.vise
FROM dbo.role_mission r
JOIN dbo.ref_role f ON f.code = r.role;

GO

