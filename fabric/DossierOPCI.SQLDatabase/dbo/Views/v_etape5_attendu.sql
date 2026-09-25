
-- --- 5 : ce que l'etape 5 attend, corrige ------------------------------
-- Le DIP au semestriel seul. Le rapport annuel et les obligations a
-- l'annuel seul. La valeur liquidative a tous les arretes.
CREATE   VIEW dbo.v_etape5_attendu AS
SELECT a.entite, a.arrete, a.exercice, a.type_arrete, a.date_arrete,
       CAST(1 AS SMALLINT) AS vl_a_publier,
       CAST(CASE WHEN a.type_arrete = 'SEMESTRIEL'
                 THEN 1 ELSE 0 END AS SMALLINT) AS dip_a_preparer,
       CAST(CASE WHEN a.type_arrete = 'ANNUEL'
                 THEN 1 ELSE 0 END AS SMALLINT) AS rapport_annuel_a_produire,
       CAST(CASE WHEN a.type_arrete = 'ANNUEL'
                 THEN 1 ELSE 0 END AS SMALLINT) AS obligation_a_calculer,
       -- Article 28 II, les 2 echeances du document periodique.
       CASE WHEN a.type_arrete = 'SEMESTRIEL'
            THEN DATEADD(WEEK, 8, a.date_arrete) END AS dip_publier_avant,
       CASE WHEN a.type_arrete = 'SEMESTRIEL'
            THEN DATEADD(WEEK, 9, a.date_arrete) END AS dip_envoyer_amf_avant
FROM dbo.arrete_mission a;

GO

