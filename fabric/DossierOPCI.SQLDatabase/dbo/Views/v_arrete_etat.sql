
-- 2. LES ARRETES DES ETATS : tout arrete de mission d'un vehicule, et l'arrete de sa colonne N-1, l'annuel de
-- l'exercice precedent du meme vehicule.
CREATE   VIEW dbo.v_arrete_etat AS
SELECT r.entite, r.arrete, r.exercice, r.porte_balance,
       p.arrete AS arrete_n_1, p.porte_balance AS porte_balance_n_1,
       CAST(CASE WHEN p.arrete IS NULL THEN 1 ELSE 0 END AS BIT) AS premier_exercice
FROM dbo.ref_arrete r
JOIN dbo.ref_entite e ON e.code = r.entite AND e.forme_vehicule IS NOT NULL
OUTER APPLY (SELECT TOP (1) x.arrete, x.porte_balance FROM dbo.ref_arrete x
             WHERE x.entite = r.entite AND x.type_arrete = 'ANNUEL' AND x.exercice < r.exercice
             ORDER BY x.exercice DESC) p
WHERE r.nature_technique = 'MISSION';

GO

