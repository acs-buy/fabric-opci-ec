CREATE   VIEW dbo.v_ctx_avancement_etapes AS
SELECT t.* FROM dbo.v_avancement_etapes t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p
              WHERE p.entite = t.entite AND p.arrete = t.arrete
                AND p.entite = p.vehicule);

GO

