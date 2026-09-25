
-- --- 5c : les mouvements du portefeuille dans la periode, rubrique 5 du DIP --
-- Demande du candidat du 06/09/2026, page « Le document d'information periodique ».
CREATE   VIEW dbo.v_client_mouvement_actif AS
SELECT m.entite + '|' + m.arrete AS cle_arrete, m.entite, m.arrete,
       m.code_actif, m.nature, m.date_mouvement, m.montant, m.prix_cession, m.frais
FROM dbo.mouvement_actif m
JOIN dbo.ref_arrete a ON a.entite = m.entite AND a.arrete = m.arrete
WHERE a.porte_balance = 1;

GO

