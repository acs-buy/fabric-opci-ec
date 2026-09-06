
-- --- depuis 63_SQL/126_ecritures_miroir_intragroupe.sql : v_ecriture_miroir_a_passer ---
-- =====================================================================
-- LES ECRITURES MIROIR DES FLUX INTRAGROUPE, DERIVEES ET NON SAISIES.
--
-- LA DECISION. Le candidat a arrete le 05/09/2026 de passer les 2 cotes
-- de chaque flux intragroupe, apres que le lot 2 a montre que 61 flux
-- sur 74 n'ont aucune ecriture en face. Le script 125 nomme le fait sans
-- le corriger ; celui-ci le corrige.
--
-- CE QUI N'EST PAS SAISI, ET C'EST L'ESSENTIEL. Aucun montant n'est
-- ecrit en dur. Chaque ecriture derive de ce que la base porte deja :
-- l'encours declare par dbo.emprunt_intragroupe, le solde du compte de
-- tresorerie de l'entite, et le compte que dbo.flux_intragroupe designe.
-- Un montant recopie a la main serait un montant a verifier a chaque
-- rejeu ; un montant derive se recalcule.
--
-- LE MODE A BLANC EST LE DEFAUT. pr_passer_ecritures_miroir s'execute
-- avec @a_blanc = 1 : elle calcule tout, montre l'effet sur l'actif net
-- de chaque entite, et N'ECRIT RIEN. Il faut @a_blanc = 0 pour que les
-- lots soient poses. Le motif est le jeu de chiffres unique du memoire :
-- ces ecritures deplacent l'actif net des filiales, donc la valeur
-- liquidative, et une execution involontaire obligerait a rejouer toutes
-- les preuves.
--
-- LE PRET EST ECARTE, ET CE CONSTAT CORRIGE LE LOT 2. Le script 125
-- concluait que « les flux sont comptabilises d'un seul cote ». C'est
-- FAUX pour les prets, et la cle etrangere sur dbo.ref_compte l'a montre
-- le 05/09/2026 en refusant le compte 4551.
-- Verifie filiale par filiale : le compte 512 n'est PAS un compte
-- bancaire, son libelle est « Emprunts lies a des actifs immobiliers »,
-- et chaque filiale y porte au credit EXACTEMENT le prix de son
-- immeuble, 8 500 000,00 pour OMEGA-SCI-1 dont le pret declare vaut
-- 5 525 000,00, soit 65 %. LA DETTE EST DONC AU BILAN. Ce qui manque
-- n'est pas la dette, c'est sa VENTILATION entre la part intragroupe et
-- le reste du financement.
-- Ajouter une dette de 74 620 000,00 aurait double le passif des 12
-- filiales. Le reclassement, lui, exigerait un compte de compte courant
-- d'associe, et LE PLAN DU RECUEIL N'EN PORTE AUCUN : la classe 4 ne
-- connait que le 45 « Actionnaires ou porteurs de parts » et la classe 5
-- le 513 « Autres emprunts ». Le compte 4551 que le script 108 a inscrit
-- dans dbo.flux_intragroupe n'existe pas au plan de l'article 411-3, et
-- c'est ce compte, non l'absence d'ecriture, qui faisait echouer le
-- rapprochement. La ventilation demande un arbitrage sur le plan de
-- comptes, non une ecriture miroir.
--
-- LES NATURES QUI RESTENT, ET LEUR EFFET. Le parametre @natures reste a
-- NULL pour toutes, ou porte la liste de celles a passer.
--   INTERET   : CHARGE chez la filiale et produit chez la mere. L'actif
--               net de la filiale BAISSE de la charge, celui de la mere
--               monte du produit, et la valeur des titres suit.
--   DIVIDENDE : DISTRIBUTION chez la filiale. Son actif net BAISSE du
--               montant distribue, que la mere a deja comptabilise en
--               produit. C'est cet ecart qui empeche la rationalisation
--               de boucler, mesure a 194 736,70 le 05/09/2026.
--
-- LA VENTE D'IMMEUBLE EST ECARTEE, ET CE N'EST PAS UN OUBLI. Le mode a
-- blanc du 05/09/2026 a montre que le flux VENTE_IMMEUBLE ne se passe
-- PAS a un seul cote. Il declare 4 656 000,00 de OMEGA-SCI-10 vers
-- OMEGA-SCI-11, compte 213 au debit et 761 au credit. Or les 2 filiales
-- portent encore chacune leur immeuble au 31/12/2025 : la cession n'est
-- comptabilisee nulle part. Passer le seul produit de cession creerait
-- un produit SANS SORTIE D'ACTIF, et gonflerait l'actif net de la
-- venderesse de 4 656 000,00. Une cession est une operation a plusieurs
-- lignes, sortie de la valeur brute, produit de cession et encaissement,
-- et le flux n'en declare qu'une. Le controle C78 la nomme ; elle
-- demande une ecriture construite, non un miroir.
--
-- LA CONTREPARTIE DU DIVIDENDE EST LA TRESORERIE, NON LE COMPTE COURANT.
-- Verifie le 05/09/2026 : la mere porte deja 658 376,00 de dividendes
-- recus au compte 73, par sa balance importee, et sa tresorerie est
-- debitrice de 7 878 253,50. Le produit est donc encaisse. Crediter le
-- compte courant 4551 chez la filiale creerait une dette intragroupe que
-- rien ne porte en face, et le compte 266 de la mere, egal aux
-- 74 620 000,00 d'encours de prets, divergerait du 4551 des filiales.
-- L'actif net de la filiale baisse de 194 736,70 dans les 2 cas : le
-- choix de la contrepartie ne change que la presentation.
--
-- LE JOURNAL EST ODR, IMPOSE PAR LA FAMILLE. La contrainte
-- ck_ecriture_journal_od lie le journal a la famille du lot : ODR pour
-- une ecriture DECIDEE, ODV pour une ecriture DERIVABLE. Le journal
-- « ODM » que ce script avait choisi n'existe pas, et la contrainte a
-- refuse l'invention d'un code : le plan de journaux est ferme.
--
-- LE STATUT EST PROPOSE, ET IL N'Y A PAS DE BROUILLON. Le second essai
-- reel a ete refuse par ck_statut : les 5 statuts sont PROPOSE, VALIDE,
-- REJETE, EXPORTE et PUBLIE. Un lot PROPOSE porte la meme garantie que
-- celle qui etait cherchee : les vues d'actif net ne lisent que VALIDE,
-- EXPORTE et PUBLIE, si bien que l'actif net ne bouge qu'au visa.
--
-- LA FAMILLE EST DECIDEE, ET CE N'EST PAS UNE QUESTION DE VOCABULAIRE.
-- Ce script a d'abord choisi DERIVABLE, au motif que rien n'etait
-- arbitre par un reviseur. Le lot est passe, il a ete vise, et L'ACTIF
-- NET N'A PAS BOUGE. La cause est dans dbo.v_anr_entite : les capitaux
-- propres se calculent en EXCLUANT les lots DERIVABLE, qui n'y sont lus
-- que pour les comptes 27 des differences d'estimation. Une ecriture
-- DERIVABLE portant un compte de capitaux propres est donc invisible
-- pour l'actif net.
-- La famille ne dit pas qui a decide, elle dit CE QUE L'ECRITURE PESE :
-- DERIVABLE pour un ecart de valorisation qui se recalcule, DECIDEE pour
-- une operation qui entre dans les capitaux propres. Une distribution de
-- dividende est de la seconde sorte. Le lot porte donc une feuille de
-- travail ET une question du questionnaire, comme
-- ck_lot_source_par_famille l'exige, et son journal est ODR.
--
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : ce qu'il y a a passer, cote par cote -----------------------
-- LA VUE NE DECIDE RIEN, ELLE CALCULE. Une ligne par cote de flux dont
-- le compte attendu ne porte aucune ecriture. Le montant, la
-- contrepartie et le sens y sont derives ; la procedure ne fait que les
-- ecrire.
CREATE   VIEW dbo.v_ecriture_miroir_a_passer AS
WITH cote AS (
    -- Le cote DEBITEUR de chaque flux : la filiale pour un pret et pour
    -- des interets, la filiale distributrice pour un dividende.
    SELECT f.id AS flux_id, f.arrete, f.nature,
           f.entite_debitrice AS entite, f.compte_debiteur AS compte,
           'DEBIT' AS sens, f.montant, f.code_actif,
           f.entite_creditrice AS contrepartie_entite,
           f.compte_crediteur  AS compte_chez_l_autre
    FROM dbo.flux_intragroupe f
    UNION ALL
    -- Le cote CREDITEUR : la mere.
    SELECT f.id, f.arrete, f.nature,
           f.entite_creditrice, f.compte_crediteur,
           'CREDIT', f.montant, f.code_actif,
           f.entite_debitrice, f.compte_debiteur
    FROM dbo.flux_intragroupe f
),
solde AS (
    SELECT c.flux_id, c.sens,
           -- Le solde du compte ATTENDU, celui que le flux designe.
           attendu.solde                        AS solde_attendu,
           -- Le solde du compte de TRESORERIE de la meme entite, qui
           -- sert de contrepartie a un reclassement.
           tresorerie.solde                     AS solde_tresorerie,
           tresorerie.compte                    AS compte_tresorerie
    FROM cote c
    OUTER APPLY (
        SELECT ABS(SUM(e.debit) - SUM(e.credit)) AS solde
        FROM dbo.v_ecriture_normalisee e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.entite = c.entite AND l.arrete = c.arrete
          AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
          AND e.compte_num LIKE c.compte + '%'
    ) AS attendu
    OUTER APPLY (
        -- LE COMPTE DE LIQUIDITES, ET LUI SEUL. La redaction precedente
        -- prenait le compte en 51 le plus crediteur : elle attrapait le
        -- 512, « Emprunts lies a des actifs immobiliers », et aurait fait
        -- payer un dividende en empruntant. Le plan de l'article 411-3
        -- ne porte qu'un compte de liquidites, le 511 « Comptes a vue »,
        -- et une distribution se paie avec lui. Le solde doit etre
        -- DEBITEUR : on ne distribue pas ce qu'on n'a pas encaisse.
        SELECT TOP 1 e.compte_num AS compte,
               SUM(e.debit) - SUM(e.credit) AS solde
        FROM dbo.v_ecriture_normalisee e
        JOIN dbo.lot_ecritures l ON l.id = e.lot_id
        WHERE l.entite = c.entite AND l.arrete = c.arrete
          AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
          AND e.compte_num = '511'
        GROUP BY e.compte_num
        HAVING SUM(e.debit) - SUM(e.credit) > 0
    ) AS tresorerie
)
SELECT c.flux_id, c.arrete, c.nature, c.entite, c.compte, c.sens,
       c.montant                                AS montant_declare,
       c.code_actif, c.contrepartie_entite,
       s.compte_tresorerie, s.solde_tresorerie,
       -- LE MONTANT RETENU. Pour un pret, le minimum de l'encours
       -- declare et du credit de tresorerie disponible ; pour une charge
       -- ou une distribution, le montant declare, qui ne se plafonne
       -- pas : une charge due est due.
       -- LE MONTANT DECLARE, SANS PLAFOND. Une charge due est due, et
       -- une distribution decidee est decidee : ni l'une ni l'autre ne
       -- se rabote sur la tresorerie disponible. Le plafond n'avait de
       -- sens que pour le reclassement d'un pret, ecarte depuis.
       CAST(c.montant AS DECIMAL (19,2))        AS montant_retenu,
       CAST(CASE WHEN c.nature = 'DIVIDENDE'
                  AND ISNULL(s.solde_tresorerie, 0) < c.montant
                 THEN 1 ELSE 0 END AS BIT)      AS plafonne,
       -- L'EFFET SUR L'ACTIF NET, dit avant d'ecrire.
       CASE WHEN c.nature = 'INTERET' AND c.sens = 'DEBIT'
                                        THEN N'baisse de la charge'
            WHEN c.nature = 'INTERET'   THEN N'hausse du produit'
            WHEN c.nature = 'DIVIDENDE' AND c.sens = 'DEBIT'
                                        THEN N'baisse de la distribution'
            ELSE N'aucun : le produit est déjà comptabilisé'
            END                                AS effet_actif_net,
       CASE WHEN c.nature = 'DIVIDENDE' AND s.compte_tresorerie IS NULL
            THEN N'à écarter : le compte 511 de l''entité ne porte aucun solde débiteur, rien n''a pu payer la distribution'
            WHEN c.nature = 'DIVIDENDE'
            THEN N'distribution au compte ' + c.compte
                 + N', contrepartie au compte ' + s.compte_tresorerie
            WHEN c.sens = 'DEBIT'
            THEN N'charge ou distribution au compte ' + c.compte
                 + N', contrepartie au compte courant'
            ELSE N'produit au compte ' + c.compte
                 + N', contrepartie au compte courant'
            END                                AS lecture
FROM cote c
JOIN solde s ON s.flux_id = c.flux_id AND s.sens = c.sens
-- LE COTE DEJA COMPTABILISE EST LAISSE TEL QUEL : la vue ne rend que ce
-- qui manque, et le rejeu ne double donc rien.
WHERE s.solde_attendu IS NULL
  -- CE QU'UN LOT MIROIR PORTE DEJA NE SE REPASSE PAS. Le compte
  -- attendu est cherche parmi les lots VALIDE, EXPORTE et PUBLIE, si
  -- bien qu'un lot au statut PROPOSE reste invisible et qu'un second
  -- appel doublerait l'ecriture. Mesure le 05/09/2026 : le cote du
  -- dividende restait « a passer » apres avoir ete pose.
  AND NOT EXISTS (
      SELECT 1 FROM dbo.v_ecriture_normalisee e2
      JOIN dbo.lot_ecritures l2 ON l2.id = e2.lot_id
      WHERE l2.entite = c.entite AND l2.arrete = c.arrete
        AND l2.motif LIKE N'%miroir%'
        AND e2.ecriture_num LIKE 'MIR-' + CAST(c.flux_id AS VARCHAR (10)) + '-%')
  -- UN ARRETE SANS BALANCE N'A RIEN A RECLASSER. Les arretes de 2026 ne
  -- portent aucune ecriture : leurs 48 cotes apparaissaient comme
  -- impossibles alors qu'ils sont seulement a venir.
  AND EXISTS (SELECT 1 FROM dbo.ref_arrete r
              WHERE r.entite = c.entite AND r.arrete = c.arrete
                AND r.porte_balance = 1)
  -- LA CESSION ET LE PRET SONT ECARTES, cf. l'entete : la premiere
  -- demande une ecriture construite, le second est deja au bilan.
  AND c.nature NOT IN ('VENTE_IMMEUBLE', 'PRET');

GO

