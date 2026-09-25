
CREATE   VIEW dbo.v_ctx_ref_compte_entite AS
SELECT ISNULL(CONVERT(nvarchar(200), t.entite), N'') + N'|'
     + ISNULL(CONVERT(nvarchar(200), t.compte_entite), N'') AS cle_ecran,
       t.*
FROM dbo.ref_compte_entite t
WHERE EXISTS (SELECT 1 FROM dbo.v_mon_perimetre p WHERE p.entite = t.entite);

GO

