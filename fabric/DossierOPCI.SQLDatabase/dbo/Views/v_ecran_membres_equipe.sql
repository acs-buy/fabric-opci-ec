
-- Section 3 : une ligne par vehicule et par connexion de membre, a la date du jour en UTC.
CREATE   VIEW dbo.v_ecran_membres_equipe AS
SELECT x.entite, x.connexion,
       (SELECT STRING_AGG(CAST(y.role AS NVARCHAR (40)), N', ') WITHIN GROUP (ORDER BY ISNULL(o.ordre, 999), y.role)
        FROM (SELECT DISTINCT r.role FROM dbo.role_mission r
              WHERE r.entite = x.entite AND r.connexion = x.connexion AND r.role IN ('ASSOCIE', 'CHEF_MISSION', 'PREPARATEUR', 'REVISEUR')
                AND r.du <= CAST(SYSUTCDATETIME() AS DATE) AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE))) y
        LEFT JOIN dbo.ref_role o ON o.code = y.role) AS roles,
       dbo.fn_decide_reouverture(x.entite, x.connexion, CAST(SYSUTCDATETIME() AS DATE)) AS decide_reouverture,
       x.entite + '|' + x.connexion AS cle_ecran
FROM (SELECT DISTINCT r.entite, r.connexion
      FROM dbo.role_mission r JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
      WHERE NULLIF(LTRIM(RTRIM(r.connexion)), N'') IS NOT NULL AND r.role IN ('ASSOCIE', 'CHEF_MISSION', 'PREPARATEUR', 'REVISEUR')
        AND r.du <= CAST(SYSUTCDATETIME() AS DATE) AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE))) x;

GO

