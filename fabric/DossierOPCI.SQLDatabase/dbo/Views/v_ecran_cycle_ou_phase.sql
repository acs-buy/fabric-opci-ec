-- 3. Les vues de l'etape 3
-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 30 : la table du segment « Cycle ou phase », une ligne par cycle et par phase, reliee au modele a
-- v_ecran_question_referentiel (cycle_ou_phase) et a aucune autre table. Cycles : nom d'usage et ordre de passage du
-- modele publie, relus a la generation (modele publie, relu le 23/10/2026 18:05 UTC) ; un cycle que le modele ne connaissait pas alors prend son
-- libelle et 50 + son ordre. Phases : libelle de ref_phase, 100 + son ordre, apres les cycles dans la liste.
CREATE   VIEW dbo.v_ecran_cycle_ou_phase AS
SELECT CAST(c.code AS VARCHAR (10)) AS code,
       CAST('CYCLE' AS VARCHAR (5)) AS genre,
       CAST(CASE c.code
                WHEN 'TRESO' THEN N'Trésorerie'
                WHEN 'TIERS' THEN N'Tiers'
                WHEN 'FRAIS' THEN N'Frais de gestion'
                WHEN 'IMMO' THEN N'Immeubles'
                WHEN 'PART' THEN N'Participations'
                WHEN 'VALO' THEN N'Valorisation'
                WHEN 'CAPITAL' THEN N'Capital'
                WHEN 'AFFECT' THEN N'Résultat'
                WHEN 'CESSIONS' THEN N'Cessions'
                WHEN 'FIN' THEN N'Placements'
                WHEN 'HB' THEN N'Hors bilan'
                ELSE c.libelle END AS NVARCHAR (400)) AS nom_usage,
       CAST(CASE c.code
                WHEN 'TRESO' THEN 1
                WHEN 'TIERS' THEN 2
                WHEN 'FRAIS' THEN 3
                WHEN 'IMMO' THEN 4
                WHEN 'PART' THEN 5
                WHEN 'VALO' THEN 6
                WHEN 'CAPITAL' THEN 7
                WHEN 'AFFECT' THEN 8
                WHEN 'CESSIONS' THEN 9
                WHEN 'FIN' THEN 10
                WHEN 'HB' THEN 11
                ELSE 50 + c.ordre END AS INT) AS ordre
FROM dbo.ref_cycle c
UNION ALL
SELECT CAST(p.code AS VARCHAR (10)), CAST('PHASE' AS VARCHAR (5)), CAST(p.libelle AS NVARCHAR (400)),
       CAST(100 + p.ordre AS INT)
FROM dbo.ref_phase p;

GO

