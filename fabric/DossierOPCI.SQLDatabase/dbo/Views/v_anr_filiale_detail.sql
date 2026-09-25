
-- --- depuis 63_SQL/107_anr_filiale_detail.sql : v_anr_filiale_detail -------------
-- --- 2 : V13, l'actif net d'une filiale compte par compte -----------
-- Ce que l'ecran E3-F1 affiche : les capitaux propres ligne a ligne, les
-- actifs et leurs differences, l'actif net reevalue, la quote-part et la
-- valeur des titres chez la mere, et le lot qui porte la valorisation.
CREATE   VIEW dbo.v_anr_filiale_detail AS
SELECT f.entite, f.arrete,
       'CAPITAUX'                          AS bloc,
       e.compte_num                        AS reference,
       COALESCE(c.libelle_complet, c.libelle) AS libelle,
       dbo.fn_classe_du_compte(e.compte_num)  AS classe,
       CAST(SUM(e.credit - e.debit) AS DECIMAL (19,2)) AS montant,
       NULL                                AS valeur_comptable,
       NULL                                AS valeur_actuelle,
       MIN(l.id)                           AS lot_id,
       MIN(l.famille)                      AS lot_famille
FROM dbo.v_anr_filiale f
JOIN dbo.lot_ecritures l ON l.entite = f.entite AND l.arrete = f.arrete
                        AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
                        AND l.famille <> 'DERIVABLE'
JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id
LEFT JOIN dbo.ref_compte c ON c.compte = e.compte_num
WHERE e.compte_num LIKE '10%' OR e.compte_num LIKE '11%'
   OR e.compte_num LIKE '12%' OR e.compte_num LIKE '13%'
   OR e.compte_num LIKE '14%' OR e.compte_num LIKE '19%'
GROUP BY f.entite, f.arrete, e.compte_num, c.libelle_complet, c.libelle

UNION ALL

-- Les actifs de la filiale, avec leur valeur comptable et leur valeur
-- actuelle : la difference d'estimation en est la soustraction.
-- dbo.v_valeur_actuelle_actif ne porte pas de libelle : le poste de
-- bilan et la source tiennent ce role.
SELECT v.entite, v.arrete,
       'ACTIFS', v.code_actif,
       N'Poste ' + v.poste_bilan + N', source : ' + LEFT(v.source, 60),
       v.nature,
       CAST(v.difference_estimation AS DECIMAL (19,2)),
       CAST(v.valeur_comptable AS DECIMAL (19,2)),
       CAST(v.valeur_actuelle AS DECIMAL (19,2)),
       NULL, NULL
FROM dbo.v_valeur_actuelle_actif v

UNION ALL

-- La valeur des titres chez la mere : l'actif net reevalue de la filiale
-- multiplie par la quote-part detenue. La valeur actuelle des titres est
-- prescrite par l'article 212-4 ; sa determination par l'actif net
-- reevalue multiplie par la quote-part est la METHODE DE LA PROFESSION,
-- que le reglement n'enonce pas.
SELECT d.entite_fille, d.arrete,
       'TITRES CHEZ LA MERE',
       d.entite_mere,
       N'Quote-part detenue : '
         + FORMAT(d.quote_part, 'P4', 'fr-FR'),
       'ART 212-4',
       CAST(f.actif_net_reevalue * d.quote_part AS DECIMAL (19,2)),
       NULL,
       CAST(f.actif_net_reevalue AS DECIMAL (19,2)),
       NULL, NULL
FROM dbo.detention d
JOIN dbo.v_anr_filiale f ON f.entite = d.entite_fille
                        AND f.arrete = d.arrete;

GO

