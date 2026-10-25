CREATE   VIEW dbo.v_obligation_par_categorie AS
WITH cat AS (
    SELECT r.categorie AS categorie_ref, r.libelle, r.taux AS taux_ref, r.article, r.ordre,
           CASE r.categorie WHEN 'RESULTAT'    THEN 'REVENUS_85'
                            WHEN 'PLUS_VALUES' THEN 'PLUS_VALUES_50'
                            WHEN 'EXONEREES'   THEN 'DIVIDENDES_SIIC_100'
                            ELSE r.categorie END AS categorie
    FROM dbo.ref_obligation_distribution r
)
SELECT s.entite + '|' + s.arrete + '|' + c.categorie AS cle,
       s.entite, s.arrete AS exercice, s.arrete,
       c.categorie, c.categorie_ref, c.libelle, c.article, c.ordre,
       b.base_calcul,
       CAST(c.taux_ref * 100 AS DECIMAL (9,6))                    AS taux,
       CAST(ROUND(b.base_calcul * c.taux_ref, 2) AS DECIMAL (19,2)) AS montant_propose,
       CAST(CASE c.categorie_ref
                 WHEN 'RESULTAT' THEN CASE WHEN k.fi IS NULL AND s.resultat_distribuable > 0
                      THEN N'À remplir : bilan de l’exercice précédent absent, frais de gestion non répartis (D. 214-124, III) ; ' + c.article
                      ELSE N'Part directe ' + FORMAT(k.pd, 'N2', 'fr-FR') + N', frais imputés ' + FORMAT(ISNULL(k.fi, 0), 'N2', 'fr-FR')
                      + N' (31/12 de N-1 seul), abattement ' + FORMAT(ROUND(pr.prix_revient_immeubles * 0.015, 2), 'N2', 'fr-FR')
                      + N', quote-part des filiales ' + FORMAT(k.qp, 'N2', 'fr-FR') + CASE WHEN k.qp_saisie = 1 THEN N' (saisie)' ELSE N' (indicative)' END
                      + N', au plus le résultat distribuable ; ' + c.article END
                 ELSE N'Calculé par le moteur sur les sommes distribuables de l’exercice ; ' + c.article
            END AS NVARCHAR (400))                                AS source,
       o.id                                                       AS obligation_id,
       o.base_calcul                                              AS base_visee,
       o.montant                                                  AS montant_vise,
       o.vise_par, o.vise_le, o.etat                              AS etat_obligation,
       CASE WHEN o.id IS NULL THEN 'A_VISER' ELSE 'VISEE' END     AS etat,
       d.montant_decide, d.date_assemblee, d.decide_par,
       s.total_distribuable, s.acomptes_verses,
       -- 07/09/2026 : le motif de refus ecrit par la procedure du bouton (138), lu a l'ecran.
       COALESCE(o.message_ecran, d.message_ecran) AS message_ecran
FROM dbo.v_sommes_distribuables s
JOIN dbo.ref_arrete a ON a.entite = s.entite AND a.arrete = s.arrete AND a.type_arrete = 'ANNUEL'
CROSS JOIN cat c
-- Decisions du candidat du 19/10/2026 (63_SQL/314) : proposition du moteur pour REVENUS_85.
-- CMF, art. L. 214-69, II, 1° et III (LEGIARTI000027810446, relu le 18/10/2026) ; D. 214-124, III (LEGIARTI000027780356).
-- Plancher a 0, plafond au resultat distribuable, frais au seul 31/12 de N-1 et mesure de la quote-part des filiales :
-- deductions ou ecarts declares, non textes (65_JOURNAL/preuves_ecran_4/obligation_resultat_modeste_essai_20261019.txt).
OUTER APPLY (SELECT TOP (1) o.* FROM dbo.obligation_distribution o
             WHERE o.entite = s.entite AND o.exercice = s.arrete AND o.categorie = c.categorie
             ORDER BY o.id DESC) AS o
CROSS APPLY (SELECT CAST(ISNULL((SELECT SUM(x.prix_de_revient) FROM dbo.actif x
                                 WHERE x.entite_detentrice = s.entite AND x.nature = 'IMMEUBLE'), 0) AS DECIMAL (19,2)) AS prix_revient_immeubles,
                    (SELECT MAX(r.arrete) FROM dbo.ref_arrete r
                     WHERE r.entite = s.entite AND r.type_arrete = 'ANNUEL' AND r.arrete < s.arrete) AS n_1) AS pr
CROSS APPLY (SELECT
       CAST(ISNULL((SELECT SUM(CASE l.code WHEN 'R_PI_1' THEN l.exercice_n ELSE -l.exercice_n END) FROM dbo.v_ligne_etat_montant l
                    WHERE l.entite = s.entite AND l.arrete = s.arrete AND l.code IN ('R_PI_1', 'R_CI_1', 'R_CI_4')), 0) AS DECIMAL (19,2)) AS pd,
       CAST(ROUND((SELECT SUM(l.exercice_n) FROM dbo.v_ligne_etat_montant l
                   WHERE l.entite = s.entite AND l.arrete = s.arrete AND l.code IN ('R_TVI', 'R_TVII'))
                * (SELECT SUM(l.exercice_n_1) FROM dbo.v_ligne_etat_montant l
                   WHERE l.entite = s.entite AND l.arrete = s.arrete AND l.code IN ('A_IMMO_1', 'A_IMMO_2'))
                / NULLIF((SELECT SUM(l.exercice_n_1) FROM dbo.v_ligne_etat_montant l
                          WHERE l.entite = s.entite AND l.arrete = s.arrete AND l.code = 'A_TOTAL'), 0), 2) AS DECIMAL (19,2)) AS fi,
       CAST(CASE WHEN o.indirect_saisi_par IS NOT NULL THEN ISNULL(o.dont_indirect_n_moins_1, 0)
                 ELSE ISNULL((SELECT SUM(ROUND(q.produits_nets * q.quote_part, 2)) FROM (
                          SELECT d.quote_part,
                                 SUM(CASE WHEN LEFT(e.compte_num, 1) = '7' AND LEFT(e.compte_num, 3) <> '775' THEN e.credit - e.debit
                                          WHEN LEFT(e.compte_num, 1) = '6' AND LEFT(e.compte_num, 4) <> '6615' AND LEFT(e.compte_num, 3) <> '675' THEN e.credit - e.debit
                                          ELSE 0 END) AS produits_nets
                          FROM dbo.detention d
                          JOIN dbo.ref_entite f ON f.code = d.entite_fille AND f.forme_sociale = 'SCI'
                          JOIN dbo.lot_ecritures l ON l.entite = d.entite_fille AND l.arrete = d.arrete
                               AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE') AND ISNULL(l.feuille_cote, '') NOT LIKE 'AFF-%'
                          JOIN dbo.ecriture e ON e.lot_id = l.id
                          WHERE d.entite_mere = s.entite AND d.arrete = pr.n_1
                          GROUP BY d.entite_fille, d.quote_part) q), 0) END AS DECIMAL (19,2)) AS qp,
       CAST(CASE WHEN o.indirect_saisi_par IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS qp_saisie) AS k
CROSS APPLY (SELECT CAST(CASE c.categorie_ref
                              WHEN 'RESULTAT' THEN
                                   CASE WHEN s.resultat_distribuable <= 0 THEN 0
                                        WHEN k.fi IS NULL THEN NULL
                                        ELSE (SELECT MIN(m) FROM (VALUES (s.resultat_distribuable),
                                                 ((CASE WHEN k.pd - k.fi - ROUND(pr.prix_revient_immeubles * 0.015, 2) > 0
                                                        THEN k.pd - k.fi - ROUND(pr.prix_revient_immeubles * 0.015, 2) ELSE 0 END)
                                                  + CASE WHEN k.qp > 0 THEN k.qp ELSE 0 END)) t (m)) END
                              WHEN 'PLUS_VALUES' THEN s.plus_values_distribuables
                              ELSE 0 END AS DECIMAL (19,2)) AS base_calcul) AS b
LEFT JOIN dbo.decision_distribution d
       ON d.entite = s.entite AND d.exercice = s.arrete AND d.categorie = c.categorie_ref;

GO

