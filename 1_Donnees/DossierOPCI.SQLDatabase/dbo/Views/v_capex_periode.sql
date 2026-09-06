
-- --- 5 : les depenses d'investissement de la periode -----------------
-- La periode va de l'arrete precedent, exclu, a l'arrete courant, inclus.
CREATE   VIEW dbo.v_capex_periode AS
WITH bornes AS (
    SELECT r.entite, r.arrete, r.date_arrete, r.exercice,
           LAG(r.date_arrete) OVER (PARTITION BY r.entite
                                    ORDER BY r.date_arrete) AS date_precedente
    FROM dbo.ref_arrete r
    WHERE r.porte_balance = 1 AND r.nature_technique <> 'REJEU'
)
SELECT b.entite, b.arrete, b.date_arrete, b.exercice, b.date_precedente,
       m.code_actif,
       CAST(SUM(m.montant) AS DECIMAL (19,2)) AS travaux_capitalises,
       COUNT(*)                                AS nombre_de_mouvements
FROM bornes b
JOIN dbo.mouvement_actif m
  ON m.entite = b.entite AND m.nature = 'TRAVAUX'
 AND m.date_mouvement <= b.date_arrete
 AND (b.date_precedente IS NULL OR m.date_mouvement > b.date_precedente)
GROUP BY b.entite, b.arrete, b.date_arrete, b.exercice, b.date_precedente,
         m.code_actif;

GO

