
CREATE VIEW dbo.v_ecran_aide AS
WITH parcours AS (
    SELECT 'Client-et-collecte' AS parcours, 1 AS ordre_parcours
    UNION ALL SELECT 'Revision-et-supervision', 2
    UNION ALL SELECT 'Valorisation', 3
    UNION ALL SELECT 'Arrete-et-livrables', 4
    UNION ALL SELECT 'Referentiels', 5
)
SELECT
    CONCAT(p.parcours, '|', a.code) AS cle_ecran,
    p.parcours,
    p.ordre_parcours,
    a.code,
    a.libelle_lien,
    a.titre_page,
    a.url,
    a.portee,
    a.feuille,
    a.ordre,
    CASE a.portee
        WHEN 'TOUS'     THEN N'Ce lien s''affiche sur tous les écrans.'
        WHEN 'PARCOURS' THEN CONCAT(N'Ce lien s''affiche sur les écrans du parcours ', a.parcours, N'.')
        ELSE                 CONCAT(N'Ce lien s''affiche sur le seul écran ', a.feuille, N'.')
    END AS message_ecran
FROM dbo.ref_aide a
JOIN parcours p ON a.portee = 'TOUS' OR a.parcours = p.parcours;

GO

