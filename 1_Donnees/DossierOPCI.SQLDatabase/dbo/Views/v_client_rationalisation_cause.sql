
-- --- 2 : la rationalisation depliee, une ligne par cause -----------------
CREATE   VIEW dbo.v_client_rationalisation_cause AS
WITH o AS (
    SELECT o.* FROM dbo.v_rationalisation_opci o
    JOIN dbo.ref_arrete r ON r.entite = o.entite AND r.arrete = o.arrete
    WHERE r.porte_balance = 1
)
SELECT entite + '|' + arrete AS cle_arrete, entite, arrete, ordre, nature, cause, montant,
       CAST(CASE WHEN montant <> 0 OR nature <> 'CAUSE' THEN 1 ELSE 0 END AS BIT) AS a_afficher
FROM o
CROSS APPLY (VALUES
    ( 1, 'OUVERTURE', N'Actif net réévalué d''ouverture',        actif_net_precedent),
    ( 2, 'CAUSE',     N'Souscriptions',                          souscriptions),
    ( 3, 'CAUSE',     N'Rachats',                               -rachats),
    ( 4, 'CAUSE',     N'Dividendes versés',                     -dividendes_verses),
    ( 5, 'CAUSE',     N'Résultat corporate',                     resultat_corporate),
    ( 6, 'CAUSE',     N'Résultat immobilier',                    resultat_immobilier),
    ( 7, 'CAUSE',     N'Résultat financier',                     resultat_financier),
    ( 8, 'CAUSE',     N'Plus-values de cession',                 plus_values_cession),
    ( 9, 'CAUSE',     N'Gain sur valorisations',                 gain_valorisations),
    (10, 'CAUSE',     N'Intérêts internes neutralisés',          interets_internes_neutralises),
    (11, 'CAUSE',     N'Ventes internes neutralisées',           ventes_internes_neutralisees),
    (12, 'CLOTURE',   N'Actif net réévalué de clôture',          actif_net_rationalise)
) AS c (ordre, nature, cause, montant);

GO

