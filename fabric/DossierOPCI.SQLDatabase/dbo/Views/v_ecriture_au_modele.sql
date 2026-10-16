
-- La vue qui porte, pour chaque ecriture, son compte d'origine et son
-- compte de restitution. Les vues d'agregation s'y appuieront.
CREATE   VIEW dbo.v_ecriture_au_modele AS
SELECT e.id AS ecriture_id, e.lot_id, l.entite, l.arrete, l.famille,
       l.statut, e.compte_num AS compte_entite,
       cm.compte_modele AS compte_modele,
       CAST(CASE WHEN cm.compte_modele
                      <> e.compte_num THEN 1 ELSE 0 END AS BIT)
                                                   AS traduit,
       e.debit, e.credit, e.ecriture_lib
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
CROSS APPLY (SELECT CAST(CASE WHEN ISNULL((SELECT TOP (1) xe.plan_propre_en_service FROM dbo.ref_entite xe WHERE xe.code = l.entite), 0) = 0
                              AND EXISTS (SELECT 1 FROM dbo.ref_compte xc WHERE xc.compte = e.compte_num)
                         THEN e.compte_num
                         ELSE ISNULL((SELECT TOP (1) xr.compte_modele FROM dbo.ref_compte_entite xr
                                      WHERE xr.entite = l.entite AND xr.compte_entite = e.compte_num AND xr.compte_modele IS NOT NULL),
                                     e.compte_num) END AS VARCHAR (20)) AS compte_modele) cm;

GO

