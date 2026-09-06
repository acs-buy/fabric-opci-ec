
-- --- 2 : l'assiette de la simulation, une ligne par exercice annuel ----
-- L'obligation de distribution ne se calcule qu'a la cloture annuelle :
-- seuls les arretes de type ANNUEL entrent ici. Le plafond se lit par
-- arrete, l'obligation par exercice, ce qui est la cle de chacune des 2
-- vues sources.
-- Le drapeau plafond_inferieur_obligation n'est pas une correction : il
-- est rendu tel quel pour que l'ecran l'affiche. Un plafond inferieur a
-- l'obligation est un fait de dossier, non une anomalie de calcul.
CREATE   VIEW dbo.v_simulation_distribution AS
WITH annuels AS (
    SELECT a.entite, a.arrete, a.exercice, a.date_arrete,
           ROW_NUMBER() OVER (PARTITION BY a.entite
                              ORDER BY a.date_arrete DESC) AS rang
    FROM dbo.v_arrete_client a
    WHERE a.type_arrete = 'ANNUEL'
)
SELECT n.entite + '|' + n.arrete AS cle_arrete,
       n.entite, n.arrete, n.exercice, n.date_arrete,
       CAST(COALESCE(o.obligation_minimale, 0) AS DECIMAL (19,2))
           AS obligation_minimale,
       COALESCE(o.categories_renseignees, 0) AS categories_renseignees,
       CAST(COALESCE(p.plafond_distribuable, 0) AS DECIMAL (19,2))
           AS plafond_distribuable,
       CAST(CASE WHEN n.rang = 1 THEN 1 ELSE 0 END AS BIT)
           AS est_dernier_exercice,
       CAST(CASE WHEN COALESCE(p.plafond_distribuable, 0)
                      < COALESCE(o.obligation_minimale, 0)
                 THEN 1 ELSE 0 END AS BIT)
           AS plafond_inferieur_obligation
FROM annuels n
LEFT JOIN dbo.v_obligation_minimale o
       ON o.entite = n.entite AND o.exercice = n.exercice
LEFT JOIN dbo.v_plafond_distribuable p
       ON p.entite = n.entite AND p.arrete = n.arrete;

GO

