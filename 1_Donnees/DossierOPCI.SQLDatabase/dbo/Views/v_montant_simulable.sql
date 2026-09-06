
-- La vue des montants simulables emploie le pas calcule.
CREATE   VIEW dbo.v_montant_simulable AS
WITH bornes AS (
    SELECT p.cle_arrete, p.entite, p.arrete, p.exercice,
           p.obligation_minimale AS bas, p.plafond_distribuable AS haut, p.pas
    FROM dbo.v_pas_simulable p
    WHERE p.plafond_distribuable >= p.obligation_minimale
)
SELECT cle_arrete, entite, arrete, exercice, montant_simulable
FROM (
    SELECT b.cle_arrete, b.entite, b.arrete, b.exercice, b.bas AS montant_simulable
    FROM bornes b
    UNION
    SELECT b.cle_arrete, b.entite, b.arrete, b.exercice, b.haut FROM bornes b
    UNION
    SELECT b.cle_arrete, b.entite, b.arrete, b.exercice,
           CAST(CEILING(b.bas / b.pas) * b.pas + e.n * b.pas AS DECIMAL (19,2))
    FROM bornes b
    JOIN dbo.v_suite_entiers e
      ON e.n <= FLOOR((b.haut - CEILING(b.bas / b.pas) * b.pas) / b.pas)
    WHERE CEILING(b.bas / b.pas) * b.pas + e.n * b.pas BETWEEN b.bas AND b.haut
) AS reunion;

GO

