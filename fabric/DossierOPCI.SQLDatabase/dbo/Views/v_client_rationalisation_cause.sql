
-- --- 2 : la rationalisation depliee, une ligne par cause -----------------
CREATE   VIEW dbo.v_client_rationalisation_cause AS
WITH o AS (
    SELECT o.* FROM dbo.v_rationalisation_opci o
    JOIN dbo.ref_arrete r ON r.entite = o.entite AND r.arrete = o.arrete
    WHERE r.porte_balance = 1 AND o.arrete_precedent IS NOT NULL
)
SELECT entite + '|' + arrete AS cle_arrete, entite, arrete, ordre, nature, cause, montant,
       CAST(CASE WHEN montant <> 0 OR nature <> 'CAUSE' THEN 1 ELSE 0 END AS BIT) AS a_afficher
FROM o
CROSS APPLY (VALUES
    ( 1, 'OUVERTURE', N'Actif net réévalué d''ouverture',        actif_net_precedent),
    ( 2, 'CAUSE',     N'Souscriptions',                          souscriptions),
    -- rachats et dividendes_verses sont deja signes en negatif par le 108 :
    -- le 06/09/2026, le signe inverse faisait monter la cascade de 3 519 975,00
    -- au lieu de la faire baisser, et son total depassait l'actif net de cloture.
    ( 3, 'CAUSE',     N'Rachats',                                rachats),
    ( 4, 'CAUSE',     N'Dividendes versés',                      dividendes_verses),
    -- 06/09/2026 : « corporate » traduit, regle 5.3 ; c'est la rubrique VI du modele de
    -- compte de resultat, article 322-2, frais de gestion et de fonctionnement externes.
    ( 5, 'CAUSE',     N'Frais de gestion et de fonctionnement',  resultat_corporate),
    ( 6, 'CAUSE',     N'Résultat immobilier',                    resultat_immobilier),
    ( 7, 'CAUSE',     N'Résultat financier',                     resultat_financier),
    ( 8, 'CAUSE',     N'Plus-values de cession',                 plus_values_cession),
    ( 9, 'CAUSE',     N'Gain sur valorisations',                 gain_valorisations),
    -- 06/09/2026, decision du candidat : produit chez la mere et charge chez les
    -- filiales sur une meme ligne, zero quand la symetrie tient ; les ventes internes
    -- ne sont plus une cause.
    (10, 'CAUSE',     N'Intérêts internes éliminés (produit mère, charge filiales)', interets_internes_elimines),
    (12, 'CLOTURE',   N'Actif net réévalué de clôture',          actif_net_rationalise)
) AS c (ordre, nature, cause, montant);

GO

