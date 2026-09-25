

-- --- 6 : E4-2b, la rationalisation par filiale ----------------------
CREATE   VIEW dbo.v_rationalisation_filiale AS
SELECT d.entite_fille                      AS filiale,
       d.entite_mere, d.arrete, d.quote_part,
       COALESCE(f.capitaux_propres_comptables, 0) AS capitaux_propres,
       COALESCE(f.differences_d_estimation, 0)    AS differences_estimation,
       COALESCE(f.actif_net_reevalue, 0)          AS actif_net_filiale,
       -- Les interets reintegres : ils sont une charge chez la filiale
       -- et un produit chez la mere, donc neutres au niveau du groupe.
       COALESCE(itr.interets, 0)                  AS interets_reintegres,
       CAST(COALESCE(f.actif_net_reevalue, 0) * d.quote_part
            AS DECIMAL (19,2))                    AS valeur_titres_a_la_quote_part,
       CAST((COALESCE(f.actif_net_reevalue, 0)
             + COALESCE(itr.interets, 0)) * d.quote_part AS DECIMAL (19,2))
                                                  AS variation_rationalisee_a,
       CAST(COALESCE(f.actif_net_reevalue, 0) * d.quote_part
            AS DECIMAL (19,2))                    AS variation_calculee_b,
       CAST(COALESCE(itr.interets, 0) * d.quote_part AS DECIMAL (19,2))
                                                  AS ecart_a_moins_b
FROM dbo.detention d
LEFT JOIN dbo.v_anr_filiale f ON f.entite = d.entite_fille
                             AND f.arrete = d.arrete
OUTER APPLY (
    SELECT SUM(x.montant) AS interets FROM dbo.flux_intragroupe x
    WHERE x.nature = 'INTERET' AND x.entite_debitrice = d.entite_fille
      AND x.arrete = d.arrete
) AS itr;

GO

