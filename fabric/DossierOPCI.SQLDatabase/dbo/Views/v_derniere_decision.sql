
-- --- 1 : la derniere decision par objet, socle de E1 et E2 ---------
-- Une seule definition de « la derniere decision », lue par les vues qui
-- en dependent.
CREATE   VIEW dbo.v_derniere_decision AS
SELECT v.nature, v.objet_ref, v.entite, v.arrete, v.cycle,
       v.decision, v.motif, v.decide_par, v.decide_le, v.propose_par
FROM dbo.visa v
WHERE v.id = (SELECT MAX(w.id) FROM dbo.visa w
              WHERE w.nature = v.nature AND w.objet_ref = v.objet_ref);

GO

