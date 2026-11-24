-- La performance des seuls arretes vises pour le client : distributions non reinvesties, pas d'annualisation ; la
-- periode court de l'arrete vise precedent (exclu) a l'arrete (inclus), et le rendement compte les distributions par part
-- de la periode, au type de la distribution par part (DECIMAL (19,4)), pour que l'arrondi soit celui de la vue de
-- calcul. Une periode sans valeur precedente ne rend aucun rendement.
CREATE   VIEW dbo.v_client_hist_performance AS
WITH h AS (
    SELECT v.entite, v.arrete, v.valeur_liquidative, v.valeur_liquidative_precedente,
           LAG(v.arrete) OVER (PARTITION BY v.entite ORDER BY v.arrete) AS arrete_precedent
    FROM dbo.v_client_hist_vl v
)
SELECT h.entite, h.arrete,
       h.valeur_liquidative,
       h.valeur_liquidative_precedente,
       d.distribution_par_part,
       CASE WHEN h.valeur_liquidative_precedente IS NULL
              OR h.valeur_liquidative_precedente = 0 THEN NULL
            ELSE CAST((h.valeur_liquidative - h.valeur_liquidative_precedente
                       + COALESCE(p.distribution_periode, 0))
                      / h.valeur_liquidative_precedente AS DECIMAL (9,6))
       END AS rendement_periode
FROM h
LEFT JOIN dbo.v_distribution_par_part d
  ON d.entite = h.entite AND d.date_valeur = h.arrete
OUTER APPLY (SELECT CAST(SUM(x.distribution_par_part) AS DECIMAL (19,4)) AS distribution_periode
             FROM dbo.v_distribution_par_part x
             WHERE x.entite = h.entite AND x.date_valeur > h.arrete_precedent AND x.date_valeur <= h.arrete) p;

GO

