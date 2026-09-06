
-- --- 3 : ce qui reste a declarer ------------------------------------
-- C81 : une ecriture dont le compte n'est connu que du plan du modele,
-- alors que son entite declare un plan propre. La ligne n'est pas une
-- faute : elle dit qu'un compte reste a rattacher, et la restitution du
-- groupe s'appuiera dessus.
CREATE   VIEW dbo.v_controle_compte_hors_plan_entite AS
SELECT l.entite, e.compte_num,
       LEFT(MAX(rc.libelle), 60)                   AS libelle_du_modele,
       COUNT(*)                                    AS ecritures,
       COUNT(DISTINCT l.arrete)                    AS arretes,
       N'ce compte n''est pas déclaré au plan de l''entité : il est lu dans le plan du modèle, et son rattachement reste à poser dans dbo.ref_compte_entite'
                                                   AS lecture
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
LEFT JOIN dbo.ref_compte rc ON rc.compte = e.compte_num
WHERE EXISTS (SELECT 1 FROM dbo.ref_compte_entite x WHERE x.entite = l.entite)
  AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite rce
                  WHERE rce.entite = l.entite
                    AND rce.compte_entite = e.compte_num)
GROUP BY l.entite, e.compte_num;

GO

