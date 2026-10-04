
-- C8 : pour la nature CYCLE, seuls les visas decides apres la conclusion en vigueur se comparent ; les visas
-- anterieurs gardent le proposant de la conclusion qu'ils jugeaient.
CREATE   VIEW dbo.v_controle_visa_proposant AS
SELECT v.id, v.nature, v.objet_ref, v.propose_par,
       dbo.fn_proposant(v.nature, v.objet_ref) AS proposant_source
FROM dbo.visa v
WHERE dbo.fn_proposant(v.nature, v.objet_ref) IS NOT NULL
  AND dbo.fn_proposant(v.nature, v.objet_ref) <> v.propose_par
  AND (v.nature <> 'CYCLE'
       OR v.decide_le > (SELECT c.conclu_le FROM dbo.conclusion_cycle c WHERE c.entite + '|' + c.arrete + '|' + c.cycle = v.objet_ref));

GO

