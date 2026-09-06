-- =====================================================================
-- LOT J du plan fusionne, deuxieme partie : les documents attendus sont
-- bornes, les 31 rapports sont rattaches a leur exigence, et le releve du
-- coffre a son premier passage.
--
-- LE DEFAUT QUE CE SCRIPT CORRIGE. dbo.v_documents_attendus, posee par le
-- script 98, croisait les 77 pieces attendues avec les 29 arretes qui
-- portent balance : 2 233 lignes, dont la plupart n'ont aucun sens. Trois
-- bornes manquaient.
--
--   LA PERIODICITE. Une piece PERMANENT se demande une fois par entite,
--   non a chaque arrete : la lettre de mission ne se redemande pas tous
--   les ans. Elle est donc attendue au PREMIER arrete de l'entite, et
--   reputee fournie ensuite. Une piece ARRETE se demande a chaque arrete.
--   Une piece EVENEMENT ne se demande que si l'evenement survient : elle
--   sort de la vue des attendus, ou elle ferait croire a un manque
--   permanent.
--
--   L'APPLICABILITE DU CYCLE. dbo.ref_cycle porte une colonne
--   applicabilite : le cycle AFFECT vaut ARRETE_CLOTURE, les 10 autres
--   valent LES_DEUX. Une piece du cycle AFFECT ne se demande donc pas a
--   un arrete semestriel, ou l'affectation du resultat n'a pas lieu.
--
--   LA RACINE DECLENCHANTE. Une piece dont la racine_declenchante est
--   renseignee ne se demande que si l'entite porte des comptes de cette
--   racine. Demander un bail a une entite qui n'a aucun immeuble est un
--   faux manque.
--
-- CE QUE LE SEMIS DES RATTACHEMENTS ETABLIT. Les 31 rapports d'evaluateur
-- sont lies a leur expertise par dbo.expertise.piece_id, ce qui dit QUELLE
-- expertise ils fondent. Mais dbo.piece_rattachement est VIDE : rien ne
-- dit quelle EXIGENCE du dossier ils satisfont, et
-- dbo.v_documents_attendus les compte donc comme manquants. Le semis les
-- rattache a la piece attendue du cycle IMMO qui les designe.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : les documents attendus, bornes ------------------------------
CREATE   VIEW dbo.v_documents_attendus AS
WITH premier_arrete AS (
    SELECT entite, MIN(date_arrete) AS premiere_date
    FROM dbo.ref_arrete WHERE porte_balance = 1
    GROUP BY entite
),
racine_portee AS (
    -- Les racines de compte que chaque entite emploie reellement, lues
    -- de ses ecritures : c'est ce qui rend une exigence pertinente.
    SELECT DISTINCT l.entite, LEFT(e.compte_num, 2) AS racine
    FROM dbo.ecriture e JOIN dbo.lot_ecritures l ON l.id = e.lot_id
)
SELECT r.entite, r.arrete, r.date_arrete, r.exercice,
       a.id                                             AS piece_attendue_id,
       a.cycle, a.phase,
       COALESCE(c.libelle, f.libelle, N'Hors cycle et hors phase')
                                                        AS rattachement_libelle,
       COALESCE(c.ordre, f.ordre, 99)                   AS ordre_affichage,
       a.libelle                                        AS exigence,
       CAST(a.obligatoire AS BIT)                       AS obligatoire,
       a.periodicite, a.racine_declenchante, a.ordre,
       (SELECT COUNT(*) FROM dbo.piece_rattachement pr
        WHERE pr.piece_attendue_id = a.id
          AND pr.entite_couverte = r.entite
          AND (pr.arrete_couvert = r.arrete
               OR a.periodicite = 'PERMANENT'))          AS pieces_fournies,
       CASE WHEN (SELECT COUNT(*) FROM dbo.piece_rattachement pr
                  WHERE pr.piece_attendue_id = a.id
                    AND pr.entite_couverte = r.entite
                    AND (pr.arrete_couvert = r.arrete
                         OR a.periodicite = 'PERMANENT')) > 0
                 THEN 'FOURNIE'
            WHEN a.obligatoire = 1 THEN 'MANQUANTE'
            ELSE 'FACULTATIVE' END                      AS etat
FROM dbo.ref_arrete r
JOIN premier_arrete p ON p.entite = r.entite
CROSS JOIN dbo.ref_piece_attendue a
LEFT JOIN dbo.ref_cycle c ON c.code = a.cycle
LEFT JOIN dbo.ref_phase f ON f.code = a.phase
WHERE r.porte_balance = 1
  -- Borne 1, la periodicite. Une piece permanente n'est attendue qu'au
  -- premier arrete de l'entite ; une piece d'evenement ne l'est jamais
  -- d'office.
  AND (a.periodicite = 'ARRETE'
       OR (a.periodicite = 'PERMANENT' AND r.date_arrete = p.premiere_date))
  -- Borne 2, l'applicabilite du cycle. Le cycle AFFECT ne vaut qu'a un
  -- arrete de cloture, sa colonne applicabilite le disant.
  AND (a.cycle IS NULL
       OR c.applicabilite = 'LES_DEUX'
       OR (c.applicabilite = 'ARRETE_CLOTURE' AND r.type_arrete = 'ANNUEL'))
  -- Borne 3, la racine declenchante. Une exigence liee a une racine de
  -- compte ne se demande qu'a l'entite qui porte cette racine.
  AND (a.racine_declenchante IS NULL
       OR EXISTS (SELECT 1 FROM racine_portee rp
                  WHERE rp.entite = r.entite
                    AND rp.racine = LEFT(a.racine_declenchante, 2)));

GO

