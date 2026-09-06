
-- --- 3 : l'equilibre du brouillon, visible en permanence ----------------
-- ' l'equilibre du lot en cours de saisie ' (P1.Ch3.S1 du corps).
CREATE   VIEW dbo.v_brouillon_equilibre AS
SELECT entite, arrete, feuille_cote,
       COUNT(*)                                    AS lignes,
       CAST(SUM(debit)  AS DECIMAL (19,2))         AS total_debit,
       CAST(SUM(credit) AS DECIMAL (19,2))         AS total_credit,
       CAST(SUM(debit) - SUM(credit) AS DECIMAL (19,2)) AS desequilibre,
       CASE WHEN SUM(debit) = SUM(credit) THEN 'VALIDABLE'
            ELSE 'DESEQUILIBRE' END                AS etat
FROM dbo.ecriture_brouillon
GROUP BY entite, arrete, feuille_cote;

GO

