
-- 3. LA DEFINITION UNIQUE DES SOMMES DISTRIBUABLES, art. 321-4 : report a nouveau des plus-values realisees nettes
-- (112, 193), report a nouveau des resultats nets anterieurs (111, 191), resultat net de l'exercice et plus et
-- moins-values realisees nettes de l'exercice, comptes de regularisation compris (lignes A +/- VIII et B +/- XI du
-- modele 322-2), acomptes verses au cours de l'exercice (129 et 198). Un compte 129 ou 198 non subdivise est lu comme
-- acompte ; sa repartition entre resultat net et plus-values est « à remplir ». La fonction porte la definition, la
-- vue v_sommes_distribuables la rend, et tout lecteur passe par l'une ou l'autre.
CREATE   FUNCTION dbo.fn_sommes_distribuables ()
RETURNS @r TABLE (entite VARCHAR (20) NOT NULL, arrete VARCHAR (20) NOT NULL,
                  resultat_distribuable DECIMAL (19, 2) NULL, plus_values_distribuables DECIMAL (19, 2) NULL,
                  total_distribuable DECIMAL (19, 2) NULL, acomptes_verses DECIMAL (19, 2) NULL,
                  acomptes_non_repartis DECIMAL (19, 2) NULL, repartition_connue BIT NULL, source NVARCHAR (200) NOT NULL,
                  PRIMARY KEY (entite, arrete))
AS BEGIN
    WITH c AS (
        SELECT lo.entite, lo.arrete,
               SUM(CASE WHEN e.compte_num LIKE '111%' OR e.compte_num LIKE '191%' THEN e.credit - e.debit ELSE 0 END) AS report_resultat,
               SUM(CASE WHEN e.compte_num LIKE '112%' OR e.compte_num LIKE '193%' THEN e.credit - e.debit ELSE 0 END) AS report_pmv,
               SUM(CASE WHEN e.compte_num LIKE '1291%' OR e.compte_num LIKE '1981%' THEN e.debit - e.credit ELSE 0 END) AS acomptes_net,
               SUM(CASE WHEN e.compte_num LIKE '1293%' OR e.compte_num LIKE '1982%' THEN e.debit - e.credit ELSE 0 END) AS acomptes_pmv,
               SUM(CASE WHEN (e.compte_num LIKE '129%' AND e.compte_num NOT LIKE '1291%' AND e.compte_num NOT LIKE '1293%')
                          OR (e.compte_num LIKE '198%' AND e.compte_num NOT LIKE '1981%' AND e.compte_num NOT LIKE '1982%')
                        THEN e.debit - e.credit ELSE 0 END) AS acomptes_non_repartis
        FROM dbo.v_ecriture_normalisee e JOIN dbo.lot_ecritures lo ON lo.id = e.lot_id
        WHERE lo.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
        GROUP BY lo.entite, lo.arrete
    ),
    r AS (
        SELECT entite, arrete,
               MAX(CASE WHEN code = 'R_RNAR' THEN exercice_n END) AS rn,
               MAX(CASE WHEN code = 'R_PMVAR' THEN exercice_n END) AS pm
        FROM dbo.fn_ligne_etat_montant() WHERE code IN ('R_RNAR', 'R_PMVAR')
        GROUP BY entite, arrete
    )
    INSERT @r
    SELECT a.entite, a.arrete,
           ISNULL(c.report_resultat, 0) + r.rn - ISNULL(c.acomptes_net, 0),
           ISNULL(c.report_pmv, 0) + r.pm - ISNULL(c.acomptes_pmv, 0),
           ISNULL(c.report_resultat, 0) + r.rn - ISNULL(c.acomptes_net, 0)
             + ISNULL(c.report_pmv, 0) + r.pm - ISNULL(c.acomptes_pmv, 0)
             - ISNULL(c.acomptes_non_repartis, 0),
           ISNULL(c.acomptes_net, 0) + ISNULL(c.acomptes_pmv, 0) + ISNULL(c.acomptes_non_repartis, 0),
           ISNULL(c.acomptes_non_repartis, 0),
           CASE WHEN ISNULL(c.acomptes_non_repartis, 0) = 0 THEN 1 ELSE 0 END,
           N'Règlement ANC n° 2021-09 modifié par le règlement ANC n° 2024-01, art. 321-4 ; plan, art. 411-3'
    FROM dbo.v_arrete_etat a
    JOIN r ON r.entite = a.entite AND r.arrete = a.arrete
    LEFT JOIN c ON c.entite = a.entite AND c.arrete = a.arrete
    WHERE a.porte_balance = 1;
    RETURN;
END;

GO

