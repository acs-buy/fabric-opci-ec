
-- --- depuis 63_SQL/95_semis_emprunts_intragroupe.sql : v_controle_emprunt_vs_balance ---
-- --- 2 : le controle de concordance entre la table et les balances ---
-- La table dit ce que l'emprunt porte, les balances disent ce qui est
-- comptabilise. Un ecart entre les 2 signale soit un emprunt oublie dans
-- les balances, soit une ecriture sans emprunt. ATTENDU zero.
CREATE   VIEW dbo.v_controle_emprunt_vs_balance AS
WITH attendu AS (
    SELECT e.reference, e.entite_emprunt, r.arrete,
           CAST(e.capital_restant AS DECIMAL (19,2))          AS dette_attendue,
           CAST(e.capital_restant * e.taux_annuel / 100.0
                AS DECIMAL (19,2))                             AS interet_attendu
    FROM dbo.emprunt_intragroupe e
-- FILTRE CORRIGE le 04/09/2026. La vue filtrait sur
-- nature_technique = 'MISSION', or UN SEUL arrete sur 31 porte cette
-- nature dans le jeu, celui de OMEGA-OPCI au 31/12/2025 : les 12 filiales
-- n'en ont aucun, et la vue rendait 0 ligne. Son zero etait un FAUX ZERO,
-- le controle ne portant sur rien. Le filtre retenu est porte_balance = 1,
-- qui designe les arretes reellement comptabilises.
    JOIN dbo.ref_arrete r ON r.entite = e.entite_emprunt
                         AND r.porte_balance = 1
    -- Le premier arrete de chaque entite est le comparatif d'ouverture :
    -- il ne porte aucune ecriture d'emprunt, et l'y exiger serait
    -- reprocher au dossier de ne pas avoir de passe.
    WHERE r.date_arrete > (SELECT MIN(r2.date_arrete) FROM dbo.ref_arrete r2
                           WHERE r2.entite = e.entite_emprunt
                             AND r2.porte_balance = 1)
),
comptabilise AS (
    SELECT e.piece_ref AS reference, l.entite, l.arrete,
           CAST(SUM(CASE WHEN e.compte_num = '512'
                         THEN e.credit - e.debit ELSE 0 END)
                AS DECIMAL (19,2))                             AS dette,
           CAST(SUM(CASE WHEN e.compte_num = '623'
                         THEN e.debit - e.credit ELSE 0 END)
                AS DECIMAL (19,2))                             AS interet
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.famille = 'IMPORTEE' AND e.piece_ref LIKE 'EI-%'
    GROUP BY e.piece_ref, l.entite, l.arrete
)
SELECT a.reference, a.entite_emprunt, a.arrete,
       a.dette_attendue, c.dette              AS dette_comptabilisee,
       a.interet_attendu, c.interet           AS interet_comptabilise,
       CAST(a.dette_attendue - COALESCE(c.dette, 0) AS DECIMAL (19,2))
           AS ecart_dette,
       CAST(a.interet_attendu - COALESCE(c.interet, 0) AS DECIMAL (19,2))
           AS ecart_interet
FROM attendu a
-- La jointure porte AUSSI sur l'entite : la piece EI-nn existe chez la
-- filiale, qui porte la dette au 512 et la charge au 623, ET chez l'OPCI,
-- qui porte le produit au 724. Sans l'entite, la jointure prenait le
-- groupe de l'OPCI, qui n'a ni 512 ni 623, et rendait 0,00 sur les
-- 25 couples : releve au rejeu du 04/09/2026.
LEFT JOIN comptabilise c ON c.reference = a.reference AND c.arrete = a.arrete
                        AND c.entite = a.entite_emprunt
WHERE a.dette_attendue <> COALESCE(c.dette, 0)
   OR a.interet_attendu <> COALESCE(c.interet, 0);

GO

