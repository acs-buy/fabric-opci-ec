
-- 7b : une entite du perimetre sans role visant a la date d'un de ses
-- arretes. Sans chef de mission a cette date, aucun visa n'y est possible.
CREATE   VIEW dbo.v_controle_entite_sans_viseur AS
SELECT r.entite, r.arrete, r.date_arrete, r.nature_technique
FROM dbo.ref_arrete r
WHERE r.nature_technique = 'MISSION'
  AND NOT EXISTS (SELECT 1 FROM dbo.role_mission m
                  JOIN dbo.ref_role f ON f.code = m.role
                  WHERE m.entite = r.entite AND f.vise = 1
                    AND m.du <= r.date_arrete
                    AND (m.au IS NULL OR m.au > r.date_arrete));

GO

