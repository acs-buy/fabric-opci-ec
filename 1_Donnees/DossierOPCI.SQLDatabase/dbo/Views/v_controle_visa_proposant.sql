
-- --- 9 : les controles ----------------------------------------------
-- C8 : un visa dont le proposant ne correspond plus a la source. Le
-- verrou le refuse a l'ecriture ; cette vue le detecte si la source
-- change apres coup. ATTENDU zero.
CREATE   VIEW dbo.v_controle_visa_proposant AS
SELECT v.id, v.nature, v.objet_ref, v.propose_par,
       dbo.fn_proposant(v.nature, v.objet_ref) AS proposant_source
FROM dbo.visa v
WHERE dbo.fn_proposant(v.nature, v.objet_ref) IS NOT NULL
  AND dbo.fn_proposant(v.nature, v.objet_ref) <> v.propose_par;

GO

