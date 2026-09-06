

-- --- 2 : les controles -----------------------------------------------
-- C45 : un modele dont les 2 sens ne se font pas face. Un modele a une
-- seule ligne, ou dont toutes les lignes vont dans le meme sens, ne
-- pre-remplit pas une ecriture : il pre-remplit une moitie d'ecriture.
-- ATTENDU zero.
CREATE   VIEW dbo.v_controle_modele_sens_unique AS
SELECT q.reference, q.cycle, COUNT(*) AS lignes,
       SUM(CASE WHEN m.sens = 'DEBIT' THEN 1 ELSE 0 END)  AS debits,
       SUM(CASE WHEN m.sens = 'CREDIT' THEN 1 ELSE 0 END) AS credits
FROM dbo.modele_ecriture m
JOIN dbo.ref_question q ON q.id = m.question_id
GROUP BY q.reference, q.cycle
HAVING SUM(CASE WHEN m.sens = 'DEBIT' THEN 1 ELSE 0 END) = 0
    OR SUM(CASE WHEN m.sens = 'CREDIT' THEN 1 ELSE 0 END) = 0;

GO

