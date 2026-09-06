
-- --- 3 : les parts detenues a la date de l'arrete ----------------------
-- v_parts_porteur porte un cumul glissant : une ligne par porteur et par
-- date de mouvement. La photographie a une date se prend donc a la
-- DERNIERE date de valeur de CHAQUE porteur qui ne depasse pas la date de
-- l'arrete, jamais a une date globale : un porteur sans mouvement dans la
-- periode detient toujours ses parts. C'est la lecture que fait deja
-- v_controle_parts_porteurs, script 51, bloc 5.
-- date_valeur est un varchar : la convention du dossier est la forme
-- AAAA-MM-JJ, sous laquelle l'ordre alphabetique est l'ordre
-- chronologique. La date de l'arrete y est ramenee par le style 23.
CREATE   VIEW dbo.v_parts_porteur_courant AS
SELECT a.entite + '|' + a.arrete AS cle_arrete,
       a.entite, a.arrete, a.exercice,
       p.id AS porteur_id, p.code, p.denomination,
       x.date_valeur,
       CAST(COALESCE(x.parts_detenues, 0) AS DECIMAL (19,4)) AS parts_detenues
FROM dbo.v_arrete_client a
JOIN dbo.porteur p ON p.entite = a.entite
OUTER APPLY (
    SELECT TOP (1) v.date_valeur, v.parts_detenues
    FROM dbo.v_parts_porteur v
    WHERE v.porteur_id = p.id
      AND v.date_valeur <= CONVERT(VARCHAR (10), a.date_arrete, 23)
    ORDER BY v.date_valeur DESC
) x;

GO

