
-- ------------------------------------------------------------------ n° 23 : les pas de la rationalisation
-- Une ligne par pas de variation de v_rationalisation_opci, dans l'ordre de la vue ; libelle_court de 13 caracteres au
-- plus pour l'axe du waterfallChart, libelle complet pour l'infobulle.
CREATE   VIEW dbo.v_ecran_rationalisation_pas AS
SELECT r.entite, r.arrete, x.ordre, CAST(x.libelle_court AS NVARCHAR (13)) AS libelle_court,
       CAST(x.libelle AS NVARCHAR (60)) AS libelle, CAST(x.montant AS DECIMAL (19,2)) AS montant,
       r.entite + '|' + r.arrete + '|' + CAST(x.ordre AS VARCHAR (2)) AS cle_ecran
FROM dbo.v_rationalisation_opci r
CROSS APPLY (VALUES
    (1, N'Souscriptions', N'Souscriptions', r.souscriptions),
    (2, N'Rachats', N'Rachats', r.rachats),
    (3, N'Dividendes', N'Dividendes versés', r.dividendes_verses),
    (4, N'Corporate', N'Résultat corporate', r.resultat_corporate),
    (5, N'Immobilier', N'Résultat immobilier', r.resultat_immobilier),
    (6, N'Financier', N'Résultat financier', r.resultat_financier),
    (7, N'Plus-values', N'Plus-values de cession', r.plus_values_cession),
    (8, N'Valorisations', N'Gain sur valorisations', r.gain_valorisations),
    (9, N'Intragroupe', N'Intérêts intragroupe éliminés', r.interets_internes_elimines)
) x (ordre, libelle_court, libelle, montant);

GO

