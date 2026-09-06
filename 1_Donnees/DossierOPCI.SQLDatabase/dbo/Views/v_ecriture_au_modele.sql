
-- La vue qui porte, pour chaque ecriture, son compte d'origine et son
-- compte de restitution. Les vues d'agregation s'y appuieront.
CREATE   VIEW dbo.v_ecriture_au_modele AS
SELECT e.id AS ecriture_id, e.lot_id, l.entite, l.arrete, l.famille,
       l.statut, e.compte_num AS compte_entite,
       dbo.fn_compte_du_modele(l.entite, e.compte_num) AS compte_modele,
       CAST(CASE WHEN dbo.fn_compte_du_modele(l.entite, e.compte_num)
                      <> e.compte_num THEN 1 ELSE 0 END AS BIT)
                                                   AS traduit,
       e.debit, e.credit, e.ecriture_lib
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id;

GO

