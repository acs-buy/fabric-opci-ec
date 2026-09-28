
-- UNE LIGNE PAR CYCLE DE CHAQUE PROGRAMME. ACTIF : toutes ses questions eligibles sont actives ;
-- PARTIEL : une partie ; INACTIF : aucune.
CREATE   VIEW dbo.v_programme_cycles AS
SELECT s.entite, s.arrete, s.programme_id, s.cycle, c.libelle, c.ordre,
       COUNT(*) AS questions_eligibles,
       SUM(CAST(s.actif AS INT)) AS questions_actives,
       SUM(CAST(s.repondue AS INT)) AS questions_repondues,
       (SELECT COUNT(*) FROM dbo.fn_comptes_du_cycle(s.entite, s.arrete, s.cycle)) AS comptes_en_balance,
       CASE WHEN SUM(CAST(s.actif AS INT)) = COUNT(*) THEN 'ACTIF'
            WHEN SUM(CAST(s.actif AS INT)) = 0 THEN 'INACTIF' ELSE 'PARTIEL' END AS etat,
       s.entite + '|' + s.arrete + '|' + s.cycle AS cle_cycle
FROM dbo.v_programme_selection s
JOIN dbo.ref_cycle c ON c.code = s.cycle
GROUP BY s.entite, s.arrete, s.programme_id, s.cycle, c.libelle, c.ordre;

GO

