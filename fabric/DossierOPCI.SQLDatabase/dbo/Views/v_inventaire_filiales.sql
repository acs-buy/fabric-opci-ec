
-- --- depuis 63_SQL/117_annexe_inventaire.sql : v_inventaire_filiales -------------
-- Le tableau des filiales et participations de l'article 336-2.
CREATE   VIEW dbo.v_inventaire_filiales AS
SELECT d.entite_mere AS entite, d.arrete,
       d.entite_fille, e.denomination,
       d.quote_part,
       -- Le controle au sens de l'article R. 214-83 du CMF n'est PAS
       -- calcule : cet article n'a pas ete lu. La colonne dit la
       -- quote-part, qui n'en est pas le critere.
       N'à qualifier : article R. 214-83 du CMF non lu'
                                                AS controle_r214_83,
       cout.montant                             AS cout_de_revient_frais_exclus,
       CAST(f.actif_net_reevalue * d.quote_part AS DECIMAL (19,2))
                                                AS valeur_actuelle_titres,
       CAST(f.actif_net_reevalue * d.quote_part - COALESCE(cout.montant, 0)
            AS DECIMAL (19,2))                  AS difference_estimation,
       imm.nombre                               AS immeubles_detenus,
       imm.natures                              AS natures_des_immeubles
FROM dbo.detention d
JOIN dbo.ref_entite e ON e.code = d.entite_fille
LEFT JOIN dbo.v_anr_filiale f ON f.entite = d.entite_fille
                             AND f.arrete = d.arrete
OUTER APPLY (
    SELECT SUM(x.debit - x.credit) AS montant
    FROM dbo.v_ecriture_normalisee x
    JOIN dbo.lot_ecritures l ON l.id = x.lot_id
    WHERE l.entite = d.entite_mere AND l.arrete = d.arrete
      AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND (x.compte_num LIKE '252%' OR x.compte_num LIKE '254%')
      AND x.comp_aux_num = d.entite_fille
) AS cout
OUTER APPLY (
    SELECT COUNT(*) AS nombre,
           STRING_AGG(CAST(y.nature AS NVARCHAR (MAX)), N', ') AS natures
    FROM dbo.actif y
    WHERE y.entite_detentrice = d.entite_fille
) AS imm;

GO

