
-- --- depuis 63_SQL/112_etats_financiers_modeles.sql : v_controle_compte_hors_modele ---
-- --- 4 : les controles ----------------------------------------------
-- C58 : un compte mouvemente qu'aucune racine des 3 modeles ne
-- rattache. C'est le controle que la specification demandait sous la
-- forme d'une verification compte par compte : il donne le meme
-- resultat sans une table de 200 lignes. ATTENDU zero.
CREATE   VIEW dbo.v_controle_compte_hors_modele AS
SELECT DISTINCT lo.entite, lo.arrete, e.compte_num,
       dbo.fn_classe_du_compte(e.compte_num) AS classe
FROM dbo.v_ecriture_normalisee e
JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
  AND NOT EXISTS (
      SELECT 1 FROM dbo.ref_ligne_etat l
      CROSS APPLY STRING_SPLIT(l.racines, ',') s
      WHERE l.racines IS NOT NULL AND e.compte_num LIKE s.value + '%');

GO

