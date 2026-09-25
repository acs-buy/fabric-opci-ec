
-- --- 3 : les parts detenues par porteur, cumul a chaque date ------------
CREATE   VIEW dbo.v_parts_porteur AS
SELECT p.entite, p.id AS porteur_id, p.code, p.denomination, m.date_valeur,
       CAST(SUM(SUM(CASE WHEN m.nature = 'SOUSCRIPTION' THEN m.nombre_parts
                         WHEN m.nature = 'RACHAT' THEN -m.nombre_parts
                         ELSE 0 END))
            OVER (PARTITION BY p.id ORDER BY m.date_valeur
                  ROWS UNBOUNDED PRECEDING) AS DECIMAL (19,4)) AS parts_detenues
FROM dbo.porteur p
JOIN dbo.mouvement_porteur m ON m.porteur_id = p.id
GROUP BY p.entite, p.id, p.code, p.denomination, m.date_valeur;

GO

