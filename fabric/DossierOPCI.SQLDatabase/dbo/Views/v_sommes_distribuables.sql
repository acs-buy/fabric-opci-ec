
-- --- depuis 63_SQL/113_livrables_annexe_et_production.sql : v_sommes_distribuables ---
-- --- 3 : O21, le plafond distribuable, 1 seule definition -----------
-- La definition du texte, article L. 214-69 du CMF, I.
CREATE   VIEW dbo.v_sommes_distribuables AS
SELECT r.entite, r.arrete,
       -- 1° : le resultat distribuable afferent aux produits, egal au
       -- resultat net augmente ou minore du report a nouveau et des
       -- comptes de regularisation.
       CAST(COALESCE(c.resultat_net, 0) + COALESCE(c.report_resultat, 0)
          + COALESCE(c.regularisation_resultat, 0) AS DECIMAL (19,2))
                                                   AS resultat_distribuable,
       -- 2° : les plus-values de cession nettes de frais, diminuees des
       -- moins-values, augmentees des resultats anterieurs.
       CAST(COALESCE(c.plus_values, 0) - COALESCE(c.moins_values, 0)
          + COALESCE(c.report_pmv, 0)
          + COALESCE(c.regularisation_pmv, 0) AS DECIMAL (19,2))
                                                   AS plus_values_distribuables,
       CAST(COALESCE(c.resultat_net, 0) + COALESCE(c.report_resultat, 0)
          + COALESCE(c.regularisation_resultat, 0)
          + COALESCE(c.plus_values, 0) - COALESCE(c.moins_values, 0)
          + COALESCE(c.report_pmv, 0)
          + COALESCE(c.regularisation_pmv, 0) AS DECIMAL (19,2))
                                                   AS total_distribuable,
       -- Les acomptes deja verses viennent en deduction de ce qui reste
       -- a mettre en paiement.
       CAST(COALESCE(c.acomptes, 0) AS DECIMAL (19,2)) AS acomptes_verses,
       N'CMF, art. L. 214-69, I, lu sur piece le 04/09/2026'
                                                   AS source
FROM dbo.ref_arrete r
OUTER APPLY (
    SELECT SUM(CASE WHEN e.compte_num LIKE '120%'
                    THEN e.credit - e.debit ELSE 0 END) AS resultat_net,
           SUM(CASE WHEN e.compte_num LIKE '111%'
                    THEN e.credit - e.debit ELSE 0 END) AS report_resultat,
           SUM(CASE WHEN e.compte_num LIKE '191%' OR e.compte_num LIKE '192%'
                    THEN e.credit - e.debit ELSE 0 END)
                                                        AS regularisation_resultat,
           SUM(CASE WHEN e.compte_num LIKE '76%'
                    THEN e.credit - e.debit ELSE 0 END) AS plus_values,
           SUM(CASE WHEN e.compte_num LIKE '66%'
                    THEN e.debit - e.credit ELSE 0 END) AS moins_values,
           SUM(CASE WHEN e.compte_num LIKE '112%'
                    THEN e.credit - e.debit ELSE 0 END) AS report_pmv,
           SUM(CASE WHEN e.compte_num LIKE '193%'
                    THEN e.credit - e.debit ELSE 0 END) AS regularisation_pmv,
           SUM(CASE WHEN e.compte_num LIKE '129%'
                    THEN e.debit - e.credit ELSE 0 END) AS acomptes
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.entite = r.entite AND l.arrete = r.arrete
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
) AS c
WHERE r.nature_technique = 'MISSION';

GO

