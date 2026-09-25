-- 169 -- La cinquieme carte de l'arrete, du decompte de lignes au reste a faire
-- 12/09/2026. La carte « Lignes de bilan actif » affichait 1 166, soit le modele de bilan
-- multiplie par 53 bilans, et 22 une fois filtree, soit ce modele lui-meme. Elle n'informait
-- personne, et le bilan de l'arrete courant est COMPLET, ses 22 lignes portant toutes une valeur.
-- Le reste a faire de l'arrete est ailleurs : 42 cellules d'annexe sur 189 attendent une valeur,
-- reparties sur 22 tableaux des articles 332 a 336. La carte change donc de sujet, du bilan a
-- l'annexe, et ce changement se porte aussi dans la maquette 42.
-- L'invariant des 5 cartes par parcours est respecte : la carte est REMPLACEE, non ajoutee.
-- 167 -- Ce que reference_num veut dire, carte par carte
-- 12/09/2026. L'audit des 11 cartes a rapport a montre que reference_num porte 3 sens differents
-- sans que rien ne le dise, et l'agent Fabric IQ s'appretait a brancher des cartes a comparaison
-- dessus. La colonne reference_nature les separe : DENOMINATEUR, ANTERIEUR, SOUS_ENSEMBLE.
-- Le cas qui a motive l'ajout : ACTIFS porte 160 et 159, LOTS_PROPOSES porte 2 et 1, et dans les
-- 2 cas la reference est une PARTIE de la valeur, les actifs calculables et les lots perimes.
-- Une carte a comparaison y aurait affiche un ecart flatteur disant l'inverse de la realite.
-- A_DECLARER est un defaut voulu et bruyant, pour qu'une carte ajoutee plus tard sans nature se
-- signale a l'ecran plutot que de tomber sans bruit dans la mauvaise categorie.
-- 166 -- La carte des acceptations, denominateur ramene aux vehicules
-- 12/09/2026. Deuxieme occurrence du meme defaut dans la meme journee, trouvee en cherchant si les
-- 15 valeurs nulles des questions d'acceptation etaient un trou du jeu ou un fait de structure.
-- C'est un fait de structure : la base porte 2 vehicules et 14 filiales, et AUCUNE filiale ne
-- porte de ligne d'acceptation ni de question. L'acceptation de mission porte sur le client.
-- La carte comparait donc 1 acceptation approuvee a 16 entites et annoncait « 15 absentes ».
-- Le rapport juste est 1 sur 2, et le seul absent est le vehicule OPCI-1.
-- Le ton reste MAUVAIS : 1 vehicule sur 2 n'a pas d'acceptation, ce qui est un vrai manquement.
CREATE VIEW dbo.v_ecran_carte AS
WITH n AS (
    /* Toutes les grandeurs, mesurees une fois. */
    SELECT
        (SELECT COUNT(*) FROM dbo.ref_entite)                                        AS entites,
        (SELECT COUNT(*) FROM dbo.ref_entite WHERE forme_vehicule IS NOT NULL)       AS vehicules,
        (SELECT SUM(arretes_ouverts) FROM dbo.v_ecran_etat_dossier)                  AS arretes_ouverts,
        (SELECT MAX(arrete) FROM dbo.arrete_mission)                                 AS dernier_arrete,
        (SELECT SUM(feuilles) FROM dbo.v_ecran_etat_dossier)                         AS feuilles,
        (SELECT SUM(feuilles_conclues) FROM dbo.v_ecran_etat_dossier)                AS feuilles_conclues,
        (SELECT SUM(expertises_manquantes) FROM dbo.v_ecran_etat_dossier)            AS exp_manquantes,
        (SELECT SUM(balances_filiales_manquantes) FROM dbo.v_ecran_etat_dossier)     AS bal_manquantes,
        (SELECT COUNT(*) FROM dbo.v_ecran_etat_dossier WHERE acceptation_statut = 'APPROUVE') AS acc_ok,
        (SELECT COUNT(*) FROM dbo.v_ecran_supervision_cycle)                         AS sup_lignes,
        (SELECT COUNT(DISTINCT entite) FROM dbo.v_ecran_supervision_cycle)           AS sup_entites,
        (SELECT COUNT(DISTINCT cycle) FROM dbo.v_ecran_supervision_cycle WHERE cycle IS NOT NULL) AS sup_cycles,
        (SELECT SUM(a_viser) FROM dbo.v_ecran_supervision_cycle)                     AS a_viser,
        (SELECT SUM(vises) FROM dbo.v_ecran_supervision_cycle)                       AS vises,
        (SELECT SUM(renvoyes) FROM dbo.v_ecran_supervision_cycle)                    AS renvoyes,
        (SELECT SUM(decisions) FROM dbo.v_ecran_supervision_cycle)                   AS decisions,
        (SELECT COUNT(*) FROM dbo.v_ecran_journal_visa WHERE issue = 'REFUSE')       AS refus,
        (SELECT SUM(difference_estimation) FROM dbo.v_differences_synthese)          AS diff_actifs,
        (SELECT COUNT(*) FROM dbo.v_differences_synthese)                            AS diff_lignes,
        (SELECT SUM(actifs) FROM dbo.v_ecran_a_generer_synthese)                     AS actifs,
        (SELECT SUM(calculables) FROM dbo.v_ecran_a_generer_synthese)                AS calculables,
        (SELECT SUM(bloques) FROM dbo.v_ecran_a_generer_synthese)                    AS bloques,
        (SELECT SUM(lots_proposes) FROM dbo.v_ecran_a_generer_synthese)              AS lots_proposes,
        (SELECT SUM(lots_perimes) FROM dbo.v_ecran_a_generer_synthese)               AS lots_perimes,
        (SELECT COUNT(*) FROM dbo.v_ecran_ratio_arrete)                              AS ratio_lignes,
        (SELECT COUNT(*) FROM dbo.v_ecran_livrables_dus)                             AS livrables,
        (SELECT COUNT(*) FROM dbo.v_ecran_livrables_dus WHERE produit_le IS NOT NULL) AS livrables_produits,
        -- LE RESTE A FAIRE DE L'ARRETE, RECTIFIE LE 12/09/2026. Le decompte des lignes de
        -- bilan actif n'informait personne : il rend 22 sur l'arrete regarde, soit le
        -- nombre de lignes du modele de bilan donc une constante, et 1 166 sans filtre,
        -- soit ce meme modele multiplie par 53 bilans. Et le bilan de l'arrete courant
        -- est COMPLET, ses 22 lignes portent toutes une valeur : il n'a pas de reste a
        -- faire. Le reste a faire de l'arrete est dans l'annexe, ou 42 cellules sur 189
        -- attendent encore une valeur, sur 22 tableaux des articles 332 a 336.
        (SELECT SUM(c.cellules_a_remplir) FROM dbo.v_cellules_a_remplir c
         WHERE c.entite = (SELECT TOP 1 v.entite FROM dbo.v_ecran_valeur_liquidative v
                           WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)
           AND c.arrete = (SELECT TOP 1 v.arrete FROM dbo.v_ecran_valeur_liquidative v
                           WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)) AS ann_a_remplir,
        (SELECT SUM(c.cellules) FROM dbo.v_cellules_a_remplir c
         WHERE c.entite = (SELECT TOP 1 v.entite FROM dbo.v_ecran_valeur_liquidative v
                           WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)
           AND c.arrete = (SELECT TOP 1 v.arrete FROM dbo.v_ecran_valeur_liquidative v
                           WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)) AS ann_cellules,
        (SELECT COUNT(*) FROM dbo.v_cellules_a_remplir c
         WHERE c.entite = (SELECT TOP 1 v.entite FROM dbo.v_ecran_valeur_liquidative v
                           WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)
           AND c.arrete = (SELECT TOP 1 v.arrete FROM dbo.v_ecran_valeur_liquidative v
                           WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)) AS ann_tableaux,
        (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel)                    AS ref_nb,
        (SELECT SUM(lignes) FROM dbo.v_ecran_inventaire_referentiel)                 AS ref_lignes,
        (SELECT SUM(lignes_modifiees) FROM dbo.v_ecran_inventaire_referentiel)       AS ref_modifiees,
        (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE lignes = 0)   AS ref_vides,
        (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE qui_tient = 'ASSOCIE') AS ref_associe,
        (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE qui_tient = 'BASE')    AS ref_base,
        (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE qui_tient = 'REVISEUR') AS ref_reviseur,
        (SELECT COUNT(*) FROM dbo.v_dernier_releve_controle)                         AS ctl_releves,
        (SELECT COUNT(*) FROM dbo.v_dernier_releve_controle WHERE anomalies > 0)     AS ctl_anomalies
),
/* Les grandeurs du dernier arrete clos du vehicule, pour les cartes de l'arrete. */
a AS (
    SELECT TOP (1) s.entite, s.arrete,
           v.valeur_liquidative, v.ecart, v.actif_net_reevalue,
           (SELECT COUNT(*) FROM dbo.v_ecran_ratio_arrete r
            WHERE r.entite = s.entite AND r.arrete = s.arrete) AS ratios,
           (SELECT COUNT(*) FROM dbo.v_ecran_ratio_arrete r
            WHERE r.entite = s.entite AND r.arrete = s.arrete
              AND ((r.sens = 'MINIMUM' AND r.ratio < r.seuil)
                OR (r.sens = 'MAXIMUM' AND r.ratio > r.seuil))) AS ratios_en_ecart,
           (SELECT SUM(montant_vise) FROM dbo.v_ecran_obligation_par_categorie o
            WHERE o.entite = s.entite AND o.arrete = s.arrete) AS obligation_visee,
           (SELECT COUNT(*) FROM dbo.v_ecran_livrables_dus l
            WHERE l.entite = s.entite AND l.arrete = s.arrete) AS livrables_arrete,
           (SELECT COUNT(*) FROM dbo.v_ecran_livrables_dus l
            WHERE l.entite = s.entite AND l.arrete = s.arrete AND l.produit_le IS NOT NULL) AS livrables_faits,
           (SELECT SUM(differences_d_estimation) FROM dbo.v_ecran_anr_entite e
            WHERE e.entite = s.entite AND e.arrete = s.arrete) AS diff_comptabilisee,
           /* 09/09/2026 : la difference des ACTIFS du meme arrete, et non de tous. Le premier jeu
              soustrayait 2 perimetres differents et rendait 28 291 330,67 au lieu de 530 000,00. */
           (SELECT SUM(difference_estimation) FROM dbo.v_differences_synthese d
            WHERE d.entite = s.entite AND d.arrete = s.arrete) AS diff_actifs_arrete
    FROM dbo.v_arrete_statut s
    LEFT JOIN dbo.v_ecran_valeur_liquidative v ON v.entite = s.entite AND v.arrete = s.arrete
    WHERE s.vise_cloture = 1
    ORDER BY s.arrete DESC
)
SELECT c.parcours, c.code, c.titre, c.valeur,
       CAST(c.valeur_num AS decimal(19, 2))    AS valeur_num,
       CAST(c.reference_num AS decimal(19, 2)) AS reference_num,
       -- CE QUE reference_num VEUT DIRE, AJOUTE LE 12/09/2026.
       -- La colonne portait 3 sens sans que rien ne le dise, et un ecran qui les confond ment.
       -- DENOMINATEUR, la valeur s'affiche alors « x / n » : 1 feuille conclue sur 68.
       -- ANTERIEUR, la reference est la meme grandeur a une date anterieure, et l'ecart a un
       --   sens : la valeur liquidative de 115,38 contre 109,22 a l'arrete precedent.
       -- SOUS_ENSEMBLE, la reference est une partie de la valeur et l'ecart n'en a AUCUN :
       --   160 actifs dont 159 calculables, 2 lots proposes dont 1 perime. Une carte a
       --   comparaison branchee la-dessus afficherait « + 1 » en vert pour dire qu'un actif est
       --   bloque, soit l'inverse de la realite.
       -- A_DECLARER est un defaut VOULU ET BRUYANT : toute carte ajoutee plus tard avec une
       -- reference et sans nature declaree ici se signalera d'elle-meme a l'ecran, au lieu de
       -- tomber sans bruit dans une categorie qui ne serait pas la sienne.
       CAST(CASE
            WHEN c.reference_num IS NULL THEN NULL
            WHEN c.code IN ('FEUILLES_CONCLUES', 'ACCEPTATIONS', 'LIVRABLES', 'RATIOS_ECART',
                            'REF_VIDES', 'REF_TENUS', 'VISES',
                            'ANNEXE_A_REMPLIR')                        THEN 'DENOMINATEUR'
            WHEN c.code IN ('VL', 'DIFF_COMPTABILISEE')                 THEN 'ANTERIEUR'
            WHEN c.code IN ('ACTIFS', 'LOTS_PROPOSES')                  THEN 'SOUS_ENSEMBLE'
            ELSE 'A_DECLARER' END AS varchar(14))   AS reference_nature,
       c.sous_ligne, c.ton, c.ordre,
       CONCAT(c.parcours, '|', c.code) AS cle_ecran
FROM n
CROSS JOIN a
CROSS APPLY (VALUES
    /* --- Client et collecte ------------------------------------------------------------ */
    ('Client-et-collecte', 'ENTITES', N'Entités au dossier',
     FORMAT(n.entites, 'N0', 'fr-FR'),
     CONCAT(FORMAT(n.vehicules, 'N0', 'fr-FR'),
            CASE WHEN n.vehicules > 1 THEN N' véhicules, ' ELSE N' véhicule, ' END,
            FORMAT(n.entites - n.vehicules, 'N0', 'fr-FR'),
            CASE WHEN n.entites - n.vehicules > 1 THEN N' filiales' ELSE N' filiale' END), 'NEUTRE', 1, n.entites, NULL),
    ('Client-et-collecte', 'ARRETES_OUVERTS', N'Arrêtés ouverts',
     FORMAT(n.arretes_ouverts, 'N0', 'fr-FR'),
     CONCAT(N'dernier ouvert le ', FORMAT(TRY_CONVERT(date, n.dernier_arrete), 'dd/MM/yyyy')),
     'NEUTRE', 2, n.arretes_ouverts, NULL),
    ('Client-et-collecte', 'FEUILLES_CONCLUES', N'Feuilles conclues',
     CONCAT(FORMAT(n.feuilles_conclues, 'N0', 'fr-FR'), ' / ', FORMAT(n.feuilles, 'N0', 'fr-FR')),
     CONCAT(FORMAT(n.feuilles - n.feuilles_conclues, 'N0', 'fr-FR'), N' en cours'), 'ALERTE', 3, n.feuilles_conclues, n.feuilles),
    ('Client-et-collecte', 'EXPERTISES_MANQUANTES', N'Expertises manquantes',
     FORMAT(n.exp_manquantes, 'N0', 'fr-FR'),
     CASE WHEN n.exp_manquantes = 0 THEN N'aucun blocage' ELSE N'bloquent l''évaluation' END,
     CASE WHEN n.exp_manquantes = 0 THEN 'BON' ELSE 'MAUVAIS' END, 4, n.exp_manquantes, NULL),
    ('Client-et-collecte', 'ACCEPTATIONS', N'Acceptations approuvées',
     -- DENOMINATEUR RECTIFIE LE 12/09/2026 : les vehicules, non toutes les entites.
     -- L'acceptation de mission porte sur le client, jamais sur chacune de ses filiales, et la
     -- base le confirme, aucune des 14 filiales ne porte de ligne d'acceptation ni de question.
     -- La carte disait donc « 1 / 16 » et « 15 absentes », en imputant a 14 filiales un
     -- manquement qui ne les concerne pas. Le rapport juste est 1 sur 2 vehicules, et le seul
     -- vraiment absent est OPCI-1. Meme faute que celle corrigee le meme jour sur les questions
     -- d'acceptation de v_etat_dossier, un denominateur pris sur une population plus large que
     -- le numerateur.
     CONCAT(FORMAT(n.acc_ok, 'N0', 'fr-FR'), ' / ', FORMAT(n.vehicules, 'N0', 'fr-FR')),
     CONCAT(FORMAT(n.vehicules - n.acc_ok, 'N0', 'fr-FR'),
            CASE WHEN n.vehicules - n.acc_ok > 1 THEN N' absentes' ELSE N' absente' END),
     CASE WHEN n.acc_ok = n.vehicules THEN 'BON' ELSE 'MAUVAIS' END, 5, n.acc_ok, n.vehicules),

    /* --- Révision et supervision ------------------------------------------------------- */
    ('Revision-et-supervision', 'SUPERVISION', N'Lignes de supervision',
     FORMAT(n.sup_lignes, 'N0', 'fr-FR'),
     CONCAT(FORMAT(n.sup_entites, 'N0', 'fr-FR'), N' entités, ',
            FORMAT(n.sup_cycles, 'N0', 'fr-FR'), N' cycles servis'), 'NEUTRE', 1, n.sup_lignes, NULL),
    ('Revision-et-supervision', 'A_VISER', N'En attente de visa',
     FORMAT(n.a_viser, 'N0', 'fr-FR'),
     CASE WHEN n.a_viser = 0 THEN N'rien n''attend' ELSE N'objets à viser' END,
     CASE WHEN n.a_viser = 0 THEN 'BON' ELSE 'ALERTE' END, 2, n.a_viser, NULL),
    ('Revision-et-supervision', 'VISES', N'Visés',
     FORMAT(n.vises, 'N0', 'fr-FR'),
     CONCAT(N'sur ', FORMAT(n.decisions, 'N0', 'fr-FR'), N' décisions'), 'BON', 3, n.vises, n.decisions),
    ('Revision-et-supervision', 'RENVOYES', N'Renvoyés',
     FORMAT(n.renvoyes, 'N0', 'fr-FR'),
     CASE WHEN n.renvoyes = 0 THEN N'aucun renvoi ouvert' ELSE N'à reprendre' END,
     CASE WHEN n.renvoyes = 0 THEN 'BON' ELSE 'MAUVAIS' END, 4, n.renvoyes, NULL),
    ('Revision-et-supervision', 'REFUS', N'Refus tracés',
     FORMAT(n.refus, 'N0', 'fr-FR'), N'au journal des visas', 'NEUTRE', 5, n.refus, NULL),

    /* --- Valorisation ------------------------------------------------------------------ */
    ('Valorisation', 'ANR', N'Actif net réévalué',
     FORMAT(a.actif_net_reevalue, 'N2', 'fr-FR'),
     CONCAT(N'au ', FORMAT(TRY_CONVERT(date, a.arrete), 'dd/MM/yyyy')), 'NEUTRE', 1, a.actif_net_reevalue, NULL),
    ('Valorisation', 'DIFF_COMPTABILISEE', N'Différence comptabilisée',
     FORMAT(a.diff_comptabilisee, 'N2', 'fr-FR'),
     N'articles 211-6 et 212-4', 'NEUTRE', 2, a.diff_comptabilisee, a.diff_actifs_arrete),
    ('Valorisation', 'ACTIFS', N'Actifs suivis',
     FORMAT(n.actifs, 'N0', 'fr-FR'),
     CONCAT(FORMAT(n.calculables, 'N0', 'fr-FR'), N' calculables, ',
            FORMAT(n.bloques, 'N0', 'fr-FR'), N' bloqué'),
     CASE WHEN n.bloques = 0 THEN 'BON' ELSE 'ALERTE' END, 3, n.actifs, n.calculables),
    ('Valorisation', 'LOTS_PROPOSES', N'Lots proposés',
     FORMAT(n.lots_proposes, 'N0', 'fr-FR'),
     CONCAT(N'dont ', FORMAT(n.lots_perimes, 'N0', 'fr-FR'), N' périmé'),
     CASE WHEN n.lots_perimes = 0 THEN 'NEUTRE' ELSE 'MAUVAIS' END, 4, n.lots_proposes, n.lots_perimes),
    ('Valorisation', 'ECART_ACTIFS_ECRITURES', N'Écart actifs moins écritures',
     FORMAT(a.diff_actifs_arrete - a.diff_comptabilisee, 'N2', 'fr-FR'),
     CASE WHEN ABS(a.diff_actifs_arrete - a.diff_comptabilisee) < 1
          THEN N'les écritures suivent les actifs'
          ELSE N'contrôle C84, à trancher' END,
     CASE WHEN ABS(a.diff_actifs_arrete - a.diff_comptabilisee) < 1 THEN 'BON' ELSE 'MAUVAIS' END, 5,
     a.diff_actifs_arrete - a.diff_comptabilisee, NULL),

    /* --- Arrêté et livrables ----------------------------------------------------------- */
    ('Arrete-et-livrables', 'VL', N'Valeur liquidative',
     FORMAT(a.valeur_liquidative, 'N2', 'fr-FR'),
     CONCAT(CASE WHEN a.ecart >= 0 THEN '+ ' ELSE '' END,
            FORMAT(a.ecart, 'N2', 'fr-FR'), N' sur l''arrêté précédent'),
     CASE WHEN a.ecart >= 0 THEN 'BON' ELSE 'MAUVAIS' END, 1, a.valeur_liquidative, a.valeur_liquidative - a.ecart),
    ('Arrete-et-livrables', 'RATIOS_ECART', N'Écarts au seuil',
     CONCAT(FORMAT(a.ratios_en_ecart, 'N0', 'fr-FR'), ' / ', FORMAT(a.ratios, 'N0', 'fr-FR')),
     N'indicatif : les 4 calculs sont à valider',
     CASE WHEN a.ratios_en_ecart = 0 THEN 'BON' ELSE 'ALERTE' END, 2, a.ratios_en_ecart, a.ratios),
    ('Arrete-et-livrables', 'OBLIGATION', N'Obligation de distribution',
     FORMAT(a.obligation_visee, 'N2', 'fr-FR'),
     N'visée, CMF article L. 214-69', 'NEUTRE', 3, a.obligation_visee, NULL),
    ('Arrete-et-livrables', 'LIVRABLES', N'Livrables produits',
     CONCAT(FORMAT(a.livrables_faits, 'N0', 'fr-FR'), ' / ', FORMAT(a.livrables_arrete, 'N0', 'fr-FR')),
     CONCAT(FORMAT(a.livrables_arrete - a.livrables_faits, 'N0', 'fr-FR'), N' à produire'),
     CASE WHEN a.livrables_faits = a.livrables_arrete THEN 'BON' ELSE 'ALERTE' END, 4, a.livrables_faits, a.livrables_arrete),
    ('Arrete-et-livrables', 'ANNEXE_A_REMPLIR', N'Cellules d''annexe à remplir',
     CONCAT(FORMAT(n.ann_a_remplir, 'N0', 'fr-FR'), ' / ', FORMAT(n.ann_cellules, 'N0', 'fr-FR')),
     CONCAT(FORMAT(n.ann_tableaux, 'N0', 'fr-FR'), N' tableaux, articles 332 à 336'),
     CASE WHEN n.ann_a_remplir = 0 THEN 'BON' ELSE 'ALERTE' END, 5, n.ann_a_remplir, n.ann_cellules),

    /* --- Référentiels ------------------------------------------------------------------ */
    ('Referentiels', 'REF_NB', N'Référentiels inventoriés',
     FORMAT(n.ref_nb, 'N0', 'fr-FR'), N'1 ligne par table de référence', 'NEUTRE', 1, n.ref_nb, NULL),
    ('Referentiels', 'REF_LIGNES', N'Lignes de référence',
     FORMAT(n.ref_lignes, 'N0', 'fr-FR'), N'toutes tables confondues', 'NEUTRE', 2, n.ref_lignes, NULL),
    ('Referentiels', 'REF_MODIFIEES', N'Lignes modifiées',
     FORMAT(n.ref_modifiees, 'N0', 'fr-FR'),
     CASE WHEN n.ref_modifiees = 0 THEN N'aucune reprise locale' ELSE N'reprises au portail' END,
     CASE WHEN n.ref_modifiees = 0 THEN 'BON' ELSE 'ALERTE' END, 3, n.ref_modifiees, NULL),
    ('Referentiels', 'REF_VIDES', N'Non relevés',
     FORMAT(n.ref_vides, 'N0', 'fr-FR'), N'tables vides à ce jour', 'ALERTE', 4, n.ref_vides, n.ref_nb),
    ('Referentiels', 'REF_TENUS', N'Tenus par l''associé',
     FORMAT(n.ref_associe, 'N0', 'fr-FR'),
     CONCAT(FORMAT(n.ref_base, 'N0', 'fr-FR'), N' par la base, ',
            FORMAT(n.ref_reviseur, 'N0', 'fr-FR'), N' par le réviseur'), 'NEUTRE', 5, n.ref_associe, n.ref_nb)
) AS c(parcours, code, titre, valeur, sous_ligne, ton, ordre, valeur_num, reference_num);
;

GO

