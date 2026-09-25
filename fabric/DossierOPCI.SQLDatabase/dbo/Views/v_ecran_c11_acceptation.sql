
CREATE   VIEW dbo.v_ecran_c11_acceptation AS
SELECT t.* FROM dbo.acceptation_mission t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

