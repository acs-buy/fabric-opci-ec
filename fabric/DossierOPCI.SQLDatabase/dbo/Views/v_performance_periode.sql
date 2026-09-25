
-- --- 4 : la performance par periode de valeur ---------------------------
-- Convention de la solution : distributions non reinvesties, pas
-- d'annualisation. Une periode sans VL precedente ne rend aucun rendement.
CREATE   VIEW dbo.v_performance_periode AS
SELECT v.entite, v.arrete,
       v.valeur_liquidative,
       v.valeur_liquidative_precedente,
       d.distribution_par_part,
       CASE WHEN v.valeur_liquidative_precedente IS NULL
              OR v.valeur_liquidative_precedente = 0 THEN NULL
            ELSE CAST((v.valeur_liquidative - v.valeur_liquidative_precedente
                       + COALESCE(d.distribution_par_part, 0))
                      / v.valeur_liquidative_precedente AS DECIMAL (9,6))
       END AS rendement_periode
FROM dbo.v_valeur_liquidative v
LEFT JOIN dbo.v_distribution_par_part d
  ON d.entite = v.entite AND d.date_valeur = v.arrete;

GO

