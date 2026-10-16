
CREATE   VIEW dbo.v_inventaire_filiales AS
SELECT d.entite_mere AS entite, d.arrete,
       d.entite_fille, e.denomination,
       d.quote_part,
       -- Le classement au sens de l'article R. 214-83 du CMF est une saisie du professionnel, obligatoire a
       -- la creation de la filiale (eligibilite_participation.controlee). Sans lien de perimetre : a classer.
       CASE ep.controlee WHEN 1 THEN N'contrôlée' WHEN 0 THEN N'non contrôlée' ELSE N'à classer' END
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
LEFT JOIN dbo.eligibilite_participation ep ON ep.entite_mere = d.entite_mere AND ep.entite_fille = d.entite_fille
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

