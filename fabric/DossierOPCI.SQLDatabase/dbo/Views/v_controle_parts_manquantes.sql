
-- --- 5 : les parts, sur les arretes qui portent une balance -------------
CREATE   VIEW dbo.v_controle_parts_manquantes AS
SELECT r.entite, r.arrete, r.type_arrete
FROM dbo.ref_arrete r
WHERE r.nature_technique = 'MISSION'
  AND r.porte_balance = 1
  AND NOT EXISTS (SELECT 1 FROM dbo.parts_en_circulation p
                  WHERE p.entite = r.entite AND p.arrete = r.arrete);

GO

