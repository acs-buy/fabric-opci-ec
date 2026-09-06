
-- --- 6 : les plus et moins-values de cession de la periode -----------
-- Article 211-14 : la difference entre le prix de cession et la valeur
-- comptable de l'actif cede, nette des frais encourus tant a
-- l'acquisition qu'a la cession.
CREATE   VIEW dbo.v_plus_value_cession AS
WITH bornes AS (
    SELECT r.entite, r.arrete, r.date_arrete, r.exercice,
           LAG(r.date_arrete) OVER (PARTITION BY r.entite
                                    ORDER BY r.date_arrete) AS date_precedente
    FROM dbo.ref_arrete r
    WHERE r.porte_balance = 1 AND r.nature_technique <> 'REJEU'
)
SELECT b.entite, b.arrete, b.date_arrete, b.exercice, m.code_actif,
       m.nature, m.date_mouvement,
       CAST(m.prix_cession AS DECIMAL (19,2))        AS prix_cession,
       CAST(m.valeur_nette_sortie AS DECIMAL (19,2)) AS valeur_nette_sortie,
       CAST(m.frais AS DECIMAL (19,2))               AS frais,
       CAST(m.prix_cession - m.valeur_nette_sortie - m.frais AS DECIMAL (19,2))
           AS plus_ou_moins_value
FROM bornes b
JOIN dbo.mouvement_actif m
  ON m.entite = b.entite AND m.nature IN ('CESSION', 'SORTIE')
 AND m.date_mouvement <= b.date_arrete
 AND (b.date_precedente IS NULL OR m.date_mouvement > b.date_precedente);

GO

