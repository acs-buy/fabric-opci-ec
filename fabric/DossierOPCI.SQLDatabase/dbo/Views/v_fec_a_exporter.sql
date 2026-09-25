-- =====================================================================
-- Critere B12 : le rejeu du fichier des ecritures comptables.
-- Le fichier produit, reimporte comme un nouveau lot, doit redonner la
-- balance de l'arrete d'origine. Profil source : la balance B0 initiale.
-- Profil source plus ajustements : la balance finale.
--
-- CE QUE CE SCRIPT AJOUTE, et pourquoi.
-- Le chargement d'un import vivait dans 11_chargement.sql, en 11 blocs
-- dont chacun exige la substitution manuelle d'un identifiant. Un rejeu
-- automatique en est impossible, et un cabinet tiers ne peut pas le
-- reproduire. Les blocs 2, 3, 5, 6, 7 et 8 sont donc repris ici en UNE
-- procedure, avec TOUTES leurs gardes, sans en retirer aucune :
--   appariement du lot et de l'import, second chargement refuse, comptes
--   non rattaches refuses, axe entite pose.
-- Le fichier physique est ecrit par 61_DEPLOIEMENT/rejeu_fec.ps1, qui
-- appelle ces procedures.
--
-- Format du fichier, article A47 A-1 du livre des procedures fiscales :
-- 18 champs, separateur de tabulation, dates en AAAAMMJJ sans separateur,
-- virgule decimale sans separateur de millier, sequence continue des
-- numeros d'ecriture. Le producteur du fichier tient ces obligations ; la
-- vue du bloc 1 les prepare, les vues de controle de 35 les verifient.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : les lignes a exporter, par entite, arrete et profil ------------
-- Le profil FISCAL ne porte que la famille importee ; le profil INTEROP
-- porte les 3. La sequence des numeros d'ecriture est continue, exigence
-- de la section VII de l'article, et elle est recalculee ici.
CREATE   VIEW dbo.v_fec_a_exporter AS
SELECT
    l.entite, l.arrete, l.famille, e.lot_id,
    CASE WHEN l.famille = 'IMPORTEE' THEN 'FISCAL' ELSE 'INTEROP' END
        AS profil_minimal,
    ROW_NUMBER() OVER (PARTITION BY l.entite, l.arrete
                       ORDER BY e.lot_id, e.id) AS rang,
    e.journal_code, e.journal_lib, e.ecriture_date,
    COALESCE(e.compte_origine,
             (SELECT MAX(r.compte_entite)
                FROM dbo.ref_compte_entite r
               WHERE r.entite = l.entite
                 AND r.compte_modele = e.compte_num
              HAVING COUNT(*) = 1),
             e.compte_num) AS compte_fichier,
    e.compte_num AS compte_modele,
    e.compte_lib, e.comp_aux_num, e.comp_aux_lib,
    e.piece_ref, e.piece_date, e.ecriture_lib, e.debit, e.credit,
    e.ecriture_let, e.date_let, e.valid_date,
    e.montant_devise, e.id_devise
FROM dbo.ecriture e
JOIN dbo.lot_ecritures l ON l.id = e.lot_id
WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE');

GO

