
-- --- 5 : l'invariant, parts des porteurs egales parts en circulation ----
-- ATTENDU : zero ligne.
CREATE   VIEW dbo.v_controle_parts_porteurs AS
SELECT c.entite, c.arrete, c.nombre_parts AS parts_en_circulation,
       COALESCE(x.parts_porteurs, 0) AS parts_porteurs,
       CAST(c.nombre_parts - COALESCE(x.parts_porteurs, 0) AS DECIMAL (19,4)) AS ecart
FROM dbo.parts_en_circulation c
OUTER APPLY (SELECT SUM(v.parts_detenues) AS parts_porteurs
             FROM dbo.v_parts_porteur v
             WHERE v.entite = c.entite
               AND v.date_valeur = (SELECT MAX(v2.date_valeur)
                                    FROM dbo.v_parts_porteur v2
                                    WHERE v2.porteur_id = v.porteur_id
                                      AND v2.date_valeur <= c.arrete)) x
WHERE c.nombre_parts <> COALESCE(x.parts_porteurs, 0);

GO

