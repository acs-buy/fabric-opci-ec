
-- --- 4 : l'invariant, les parts a l'arrete egalent les parts emises ----
-- ATTENDU : zero ligne. Le meme invariant que le bloc 5 du script 51,
-- porte cette fois sur la vue que le modele semantique client consomme.
CREATE   VIEW dbo.v_controle_parts_courant AS
SELECT c.entite, c.arrete,
       c.nombre_parts AS parts_emises,
       COALESCE(x.parts_porteurs, 0) AS parts_porteurs,
       CAST(c.nombre_parts - COALESCE(x.parts_porteurs, 0)
            AS DECIMAL (19,4)) AS ecart
FROM dbo.parts_en_circulation c
JOIN dbo.v_arrete_client a
  ON a.entite = c.entite AND a.arrete = c.arrete
OUTER APPLY (SELECT SUM(v.parts_detenues) AS parts_porteurs
             FROM dbo.v_parts_porteur_courant v
             WHERE v.entite = c.entite AND v.arrete = c.arrete) x
WHERE c.nombre_parts <> COALESCE(x.parts_porteurs, 0);

GO

