-- =====================================================================
-- LES ECRITURES DE SOLDE, SCINDEES COMME LES CHARGES QU'ELLES SOLDENT.
--
-- CE QUE LA TRADUCTION DE OMEGA-SCI-1 A LAISSE. Le compte 623 du modele
-- se repartit entre le 6611, interets des emprunts et dettes, et le
-- 6615, interets des comptes courants, selon le compte auxiliaire. Ses
-- 2 charges de l'exercice ont donc ete correctement aiguillees :
-- 71 400,00 au 6611, sans auxiliaire, et 331 500,00 au 6615, avec
-- l'auxiliaire OMEGA-OPCI.
-- Mais le virement au compte de resultat solde le 623 D'UN SEUL TRAIT,
-- pour 402 900,00, et il ne porte aucun auxiliaire : il est donc alle
-- tout entier au 6611. Resultat mesure le 05/09/2026 : le 6611 ressort
-- CREDITEUR de 331 500,00 et le 6615 DEBITEUR d'autant, alors qu'un
-- compte de charges est debiteur.
--
-- CE QUI N'EST PAS EN CAUSE. Le solde du compte 623 au niveau du modele
-- reste nul, et aucune des 377 grandeurs figees n'a bouge. Le defaut est
-- une VENTILATION fausse a l'interieur d'une nature, non un montant faux.
--
-- LA REGLE : UNE ECRITURE DE SOLDE SUIT CE QU'ELLE SOLDE. Elle se scinde
-- dans les memes proportions que les ecritures qu'elle vient annuler,
-- comptees sur le meme compte du modele, la meme entite et le meme
-- arrete. La proportion n'est pas choisie, elle est constatee.
--
-- COMMENT UNE ECRITURE DE SOLDE SE RECONNAIT. Par son numero, « DET »,
-- que le script 69 pose lors de la determination du resultat. Le
-- critere est etroit et c'est voulu : elargir a toute la famille DECIDEE
-- ferait scinder des ecritures de revision qui n'ont rien a solder.
--
-- L'EQUILIBRE DU LOT EST PRESERVE : une ligne devient 2 lignes de meme
-- sens dont la somme egale la premiere, et le declencheur
-- tr_lot_equilibre ne voit donc rien passer.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : ce qu'il y a a scinder -------------------------------------
CREATE   VIEW dbo.v_solde_a_scinder AS
WITH solde AS (
    -- Les ecritures de solde, avec le compte du modele qu'elles soldent.
    SELECT e.id AS ecriture_id, e.lot_id, l.entite, l.arrete,
           e.compte_num AS compte_ecrit,
           dbo.fn_compte_du_modele(l.entite, e.compte_num) AS compte_modele,
           e.debit, e.credit, e.ecriture_num, e.ecriture_lib,
           e.journal_code, e.journal_lib, e.ecriture_date, e.compte_lib,
           e.famille
    FROM dbo.ecriture e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE e.ecriture_num = 'DET'
),
soldees AS (
    -- Les ecritures que le solde annule, ventilees par compte ecrit.
    SELECT l.entite, l.arrete,
           dbo.fn_compte_du_modele(l.entite, e.compte_num) AS compte_modele,
           e.compte_num                                    AS compte_ecrit,
           MAX(e.comp_aux_num)                             AS comp_aux_num,
           SUM(e.debit - e.credit)                         AS mouvement
    FROM dbo.ecriture e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE e.ecriture_num <> 'DET'
    -- LE GROUPE EST LE COMPTE ECRIT, NON LE COUPLE AVEC L AUXILIAIRE.
    -- Grouper aussi par auxiliaire ferait compter 2 parts la ou une
    -- entite non encore traduite porte le meme compte avec et sans
    -- auxiliaire : la scission n aurait alors rien a separer, les 2
    -- parts visant le meme compte.
    GROUP BY l.entite, l.arrete,
             dbo.fn_compte_du_modele(l.entite, e.compte_num),
             e.compte_num
    HAVING SUM(e.debit - e.credit) <> 0
)
-- LA PREMIERE PART REPREND LE RESTE. Les parts sont arrondies au
-- centime, et leur somme peut differer de l ecriture d origine. La part
-- de rang 1 se calcule donc par difference, si bien que la scission
-- totalise toujours exactement ce qu elle remplace.
SELECT q.*,
       CASE WHEN q.rang = 1
            THEN q.credit - SUM(CASE WHEN q.rang > 1 THEN q.credit_part
                                     ELSE 0 END)
                            OVER (PARTITION BY q.ecriture_id)
            ELSE q.credit_part END                     AS credit_ajuste,
       CASE WHEN q.rang = 1
            THEN q.debit - SUM(CASE WHEN q.rang > 1 THEN q.debit_part
                                    ELSE 0 END)
                           OVER (PARTITION BY q.ecriture_id)
            ELSE q.debit_part END                      AS debit_ajuste
FROM (
SELECT s.ecriture_id, s.lot_id, s.entite, s.arrete, s.compte_modele,
       s.compte_ecrit                                  AS compte_actuel,
       d.compte_ecrit                                  AS compte_cible,
       d.comp_aux_num,
       s.debit, s.credit, s.ecriture_num, s.ecriture_lib,
       s.journal_code, s.journal_lib, s.ecriture_date, s.compte_lib,
       s.famille,
       d.mouvement,
       SUM(ABS(d.mouvement)) OVER (PARTITION BY s.ecriture_id)
                                                       AS mouvement_total,
       -- LA PART, ARRONDIE AU CENTIME. Le reste eventuel se rattrape sur
       -- la derniere ligne, faute de quoi la scission ne totaliserait pas
       -- l'ecriture d'origine.
       CAST(s.credit * ABS(d.mouvement)
            / NULLIF(SUM(ABS(d.mouvement)) OVER (PARTITION BY s.ecriture_id), 0)
            AS DECIMAL (19,2))                         AS credit_part,
       CAST(s.debit * ABS(d.mouvement)
            / NULLIF(SUM(ABS(d.mouvement)) OVER (PARTITION BY s.ecriture_id), 0)
            AS DECIMAL (19,2))                         AS debit_part,
       COUNT(*) OVER (PARTITION BY s.ecriture_id)      AS parts,
       ROW_NUMBER() OVER (PARTITION BY s.ecriture_id
                          ORDER BY d.compte_ecrit)     AS rang
FROM solde s
JOIN soldees d ON d.entite = s.entite AND d.arrete = s.arrete
              AND d.compte_modele = s.compte_modele
) AS q;

GO

