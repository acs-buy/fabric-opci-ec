
-- --- 4 : la vue du maintien requis, par entite --------------------------
-- Le dernier arrete annuel enregistre, l'etat de son maintien, et le
-- verdict d'ouverture du prochain arrete.
CREATE   VIEW dbo.v_maintien_requis AS
WITH dernier AS (
    SELECT am.entite, MAX(am.arrete) AS dernier_arrete_annuel
    FROM dbo.arrete_mission am
    WHERE am.type_arrete = 'ANNUEL'
    GROUP BY am.entite
)
SELECT d.entite,
       d.dernier_arrete_annuel,
       m.statut         AS statut_maintien,
       m.decision,
       m.approuve_par,
       m.approuve_le,
       CASE WHEN m.statut = 'APPROUVE' THEN 'OUVERTURE_AUTORISEE'
            ELSE 'OUVERTURE_REFUSEE'
       END AS prochain_arrete
FROM dernier d
LEFT JOIN dbo.maintien_mission m
       ON m.entite = d.entite
      AND m.arrete_conclu = d.dernier_arrete_annuel;

GO

