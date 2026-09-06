
-- C43 : une acceptation ou un maintien approuve sans visa dans la table
-- des visas. La procedure ecrit les 2 : un ecart signale une ecriture
-- directe en table, hors procedure. ATTENDU 0.
CREATE   VIEW dbo.v_controle_decision_sans_visa AS
SELECT 'ACCEPTATION' AS nature, a.entite, NULL AS arrete_conclu,
       a.statut, a.decision, a.approuve_par
FROM dbo.acceptation_mission a
WHERE a.statut IN ('APPROUVE', 'REFUSE')
  AND NOT EXISTS (SELECT 1 FROM dbo.visa v
                  WHERE v.nature = 'ACCEPTATION' AND v.entite = a.entite)
UNION ALL
SELECT 'MAINTIEN', m.entite, m.arrete_conclu, m.statut, m.decision,
       m.approuve_par
FROM dbo.maintien_mission m
WHERE m.statut IN ('APPROUVE', 'REFUSE')
  AND NOT EXISTS (SELECT 1 FROM dbo.visa v
                  WHERE v.nature = 'MAINTIEN' AND v.entite = m.entite
                    AND v.arrete = m.arrete_conclu);

GO

