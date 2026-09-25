
CREATE   VIEW dbo.v_a_generer_synthese AS
SELECT g.entite, g.arrete, g.exercice,
       COUNT(*)                                              AS actifs,
       SUM(CASE WHEN g.etat_generation = 'CALCULABLE' THEN 1 ELSE 0 END)
                                                             AS calculables,
       SUM(CASE WHEN g.etat_generation <> 'CALCULABLE' THEN 1 ELSE 0 END)
                                                             AS bloques,
       CAST(SUM(CASE WHEN g.etat_generation = 'CALCULABLE'
                     THEN g.difference_estimation ELSE 0 END) AS DECIMAL (19,2))
                                                             AS variation_calculable,
       (SELECT COUNT(*) FROM dbo.demande_reevaluation d
        WHERE d.entite = g.entite AND d.arrete = g.arrete
          AND d.etat = 'EN_ATTENTE')                         AS demande_en_attente,
       (SELECT COUNT(*) FROM dbo.lot_ecritures l
        WHERE l.entite = g.entite AND l.arrete = g.arrete
          AND l.statut = 'PROPOSE')                          AS lots_proposes,
       (SELECT COUNT(*) FROM dbo.lot_ecritures l
        WHERE l.entite = g.entite AND l.arrete = g.arrete
          AND l.perime_le IS NOT NULL AND l.statut = 'PROPOSE')
                                                             AS lots_perimes,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       (SELECT TOP (1) s.message_ecran FROM dbo.synthese_proposee s
        WHERE s.entite = g.entite AND s.arrete = g.arrete ORDER BY s.id DESC) AS message_ecran
FROM dbo.v_a_generer g
GROUP BY g.entite, g.arrete, g.exercice;

GO

