
-- --- 4 : la distribution par part, par entite et date de valeur ---------
CREATE   VIEW dbo.v_distribution_par_part AS
SELECT p.entite, m.date_valeur,
       CAST(SUM(m.montant) AS DECIMAL (19,2)) AS distribution_totale,
       CAST(SUM(m.montant) / c.nombre_parts AS DECIMAL (19,4)) AS distribution_par_part
FROM dbo.mouvement_porteur m
JOIN dbo.porteur p ON p.id = m.porteur_id
JOIN dbo.parts_en_circulation c
  ON c.entite = p.entite AND c.arrete = m.date_valeur
WHERE m.nature = 'DISTRIBUTION'
GROUP BY p.entite, m.date_valeur, c.nombre_parts;

GO

