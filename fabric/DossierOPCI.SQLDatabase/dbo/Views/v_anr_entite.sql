
-- --- depuis 63_SQL/46_anr_vl.sql : v_anr_entite ----------------------------------
-- =====================================================================
-- Tranche T3, critere B7 : l'actif net reevalue de toute entite et la
-- valeur liquidative par part. Article 333-3 : actif net (= capitaux
-- propres) ; article 321-6 : la classe 19 appartient aux capitaux
-- propres ; article L. 214-51 du CMF : la valeur liquidative.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : l'ANR de toute entite, classe 19 comprise ---------------------
-- Meme charpente que v_anr_filiale (42) : capitaux propres des lots non
-- derivables, plus differences d'estimation des lots derivables (27x),
-- perimetre en union. Deux ecarts voulus avec la vue de 42 : le prefixe 19
-- entre dans les capitaux propres, et les differences se rattachent a
-- l'entite du lot, non a l'entite detentrice de l'actif.
CREATE   VIEW dbo.v_anr_entite AS
-- LA VUE LIT LE SOCLE, NON LA TABLE. dbo.v_ecriture_normalisee rend le
-- compte du MODELE, quel que soit le plan dans lequel l'ecriture a ete
-- passee : une filiale qui portera demain son financement au 164 du plan
-- comptable general sera lue ici au 512 du modele, sans que la presente
-- vue ait a le savoir. Reprise le 05/09/2026, avant la traduction des
-- ecritures des filiales.
WITH capitaux AS (
    SELECT e.entite, e.arrete,
           SUM(e.credit - e.debit) AS capitaux_propres_comptables
    FROM dbo.v_ecriture_normalisee e
    WHERE e.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e.famille <> 'DERIVABLE'
      AND (e.compte_num LIKE '10%' OR e.compte_num LIKE '11%'
        OR e.compte_num LIKE '12%' OR e.compte_num LIKE '13%'
        OR e.compte_num LIKE '14%' OR e.compte_num LIKE '19%')
    GROUP BY e.entite, e.arrete
),
ecarts AS (
    SELECT e.entite, e.arrete,
           SUM(e.debit - e.credit) AS differences_d_estimation
    FROM dbo.v_ecriture_normalisee e
    WHERE e.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND e.famille = 'DERIVABLE'
      AND e.compte_num LIKE '27%'
    GROUP BY e.entite, e.arrete
),
perimetre AS (
    SELECT entite, arrete FROM capitaux
    UNION
    SELECT entite, arrete FROM ecarts
)
SELECT p.entite, p.arrete,
       CAST(COALESCE(c.capitaux_propres_comptables, 0) AS DECIMAL (19,2))
           AS capitaux_propres_comptables,
       CAST(COALESCE(d.differences_d_estimation, 0) AS DECIMAL (19,2))
           AS differences_d_estimation,
       CAST(COALESCE(c.capitaux_propres_comptables, 0)
          + COALESCE(d.differences_d_estimation, 0) AS DECIMAL (19,2))
           AS actif_net_reevalue
FROM perimetre p
LEFT JOIN capitaux c ON c.entite = p.entite AND c.arrete = p.arrete
LEFT JOIN ecarts d ON d.entite = p.entite AND d.arrete = p.arrete;

GO

