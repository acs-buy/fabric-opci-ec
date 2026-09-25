
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
                 WHEN 'RESULTAT' THEN N'Resultat distribuable afferent aux produits, resultat net et report a nouveau, '
                      + FORMAT(s.resultat_distribuable, 'N2', 'fr-FR') + N', diminue de l''abattement de 1,5 % du prix de revient des immeubles detenus directement, '
                      + FORMAT(pr.prix_revient_immeubles, 'N2', 'fr-FR') + N', soit ' + FORMAT(ROUND(pr.prix_revient_immeubles * 0.015, 2), 'N2', 'fr-FR')
                      + N' ; ' + c.article
                 ELSE N'Calcule par le moteur sur les sommes distribuables de l''exercice ; ' + c.article
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
-- L'ABATTEMENT, II, 1° : 1,5 % du prix de revient des immeubles detenus directement
-- (famille IMMEUBLE du patrimoine valorise), retranche de la seule fraction resultat.
CROSS APPLY (SELECT CAST(ISNULL((SELECT SUM(p.valeur_comptable) FROM dbo.v_patrimoine_valorise p
                                 WHERE p.entite = s.entite AND p.arrete = s.arrete
                                   AND p.famille = 'IMMEUBLE'), 0) AS DECIMAL (19,2)) AS prix_revient_immeubles) AS pr
CROSS APPLY (SELECT CAST(CASE c.categorie_ref
                              WHEN 'RESULTAT'    THEN s.resultat_distribuable
                                                      - ROUND(pr.prix_revient_immeubles * 0.015, 2)
                              WHEN 'PLUS_VALUES' THEN s.plus_values_distribuables
                              ELSE 0 END AS DECIMAL (19,2)) AS base_calcul) AS b
OUTER APPLY (SELECT TOP (1) o.* FROM dbo.obligation_distribution o
             WHERE o.entite = s.entite AND o.exercice = s.arrete AND o.categorie = c.categorie
             ORDER BY o.id DESC) AS o
LEFT JOIN dbo.decision_distribution d
       ON d.entite = s.entite AND d.exercice = s.arrete AND d.categorie = c.categorie_ref;

GO

