

-- --- 8 : les contrôles -----------------------------------------------
-- C42 : un arrete ouvert dont la nature n'est pas au referentiel. Les 2
-- cles etrangeres du bloc 3 l'interdisent : la vue le mesure. ATTENDU 0.
CREATE   VIEW dbo.v_controle_nature_arrete_inconnue AS
SELECT 'arrete_mission' AS table_source, entite, arrete, type_arrete
FROM dbo.arrete_mission a
WHERE NOT EXISTS (SELECT 1 FROM dbo.ref_nature_arrete n
                  WHERE n.code = a.type_arrete)
UNION ALL
SELECT 'ref_arrete', entite, arrete, type_arrete
FROM dbo.ref_arrete r
WHERE NOT EXISTS (SELECT 1 FROM dbo.ref_nature_arrete n
                  WHERE n.code = r.type_arrete);

GO

