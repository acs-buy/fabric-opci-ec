
-- Le rapprochement de la saisie et du cumul des mouvements. Un ecart
-- n'est pas une anomalie de la base : il dit que le registre des
-- porteurs et les mouvements enregistres divergent, ce que l'etape 1
-- doit lever avant la publication de la valeur liquidative.
CREATE   VIEW dbo.v_parts_rapprochees AS
SELECT p.entite, p.arrete,
       p.nombre_parts                             AS parts_saisies,
       p.source,
       cum.parts_cumulees,
       p.nombre_parts - COALESCE(cum.parts_cumulees, 0) AS ecart,
       CAST(CASE WHEN cum.parts_cumulees IS NULL THEN 0
                 WHEN ABS(p.nombre_parts - cum.parts_cumulees) < 0.0001
                 THEN 1 ELSE 0 END AS BIT)        AS rapproche,
       CASE WHEN cum.parts_cumulees IS NULL
            THEN N'aucun mouvement de porteur a cette date : le cumul n''est pas calculable'
            WHEN ABS(p.nombre_parts - cum.parts_cumulees) < 0.0001
            THEN N'la saisie et le cumul des mouvements concordent'
            ELSE N'la saisie et le cumul des mouvements divergent : lever l''ecart avant de publier'
            END                                   AS lecture,
       p.saisi_par, p.saisi_le
FROM dbo.parts_en_circulation p
OUTER APPLY (
    SELECT SUM(CASE WHEN m.nature = 'RACHAT' THEN -m.nombre_parts
                    ELSE m.nombre_parts END) AS parts_cumulees
    FROM dbo.mouvement_porteur m
    JOIN dbo.porteur pt ON pt.id = m.porteur_id
    WHERE pt.entite = p.entite
      AND m.date_valeur <= CONVERT(DATE, p.arrete)
) AS cum;

GO

