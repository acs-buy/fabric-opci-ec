CREATE   VIEW dbo.v_rationalisation_opci AS
WITH bornes AS (
    SELECT r.entite, r.arrete, r.date_arrete,
           -- L'ARRETE PRECEDENT SE CHERCHE PARMI CEUX QUI PORTENT
           -- BALANCE, non parmi les seuls arretes de mission. Mesure du
           -- 04/09/2026 : un seul arrete portait nature_technique
           -- MISSION avant le semis de 2026, si bien que le 31/12/2025
           -- n'avait aucun precedent et partait d'un actif net de 0,00,
           -- ce qui expliquait a lui seul 146 878 575,00 d'ecart. Le
           -- comparatif du 31/12/2024 porte balance sans etre un arrete
           -- de mission du jeu.
           (SELECT MAX(p.arrete) FROM dbo.ref_arrete p
            WHERE p.entite = r.entite AND p.porte_balance = 1
              AND p.arrete < r.arrete) AS arrete_precedent
    FROM dbo.ref_arrete r
    WHERE r.nature_technique = 'MISSION'
),
-- LE LOT DE DETERMINATION DU RESULTAT EST EXCLU, et sans cela la
-- rationalisation lit zero partout. Mesure du 04/09/2026 : les 3
-- rubriques de resultat de l'OPCI rendent 0,00 chacune, parce que le
-- script 69 vire les comptes de classe 6 et 7 au compte 120 pour solde.
-- La balance apres determination du resultat est correcte
-- comptablement, mais le resultat ne s'y lit plus par rubrique. La
-- rationalisation lit donc les comptes de resultat AVANT ce virement,
-- en ecartant les lots portes par une feuille du cycle AFFECT.
resultat AS (
    SELECT l.entite, l.arrete, rr.famille,
           SUM(e.credit - e.debit) AS montant
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    JOIN dbo.ref_compte c ON c.compte = e.compte_num
    JOIN dbo.ref_rubrique_resultat rr ON rr.code = c.rubrique_resultat
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND (l.feuille_cote IS NULL OR l.feuille_cote NOT LIKE 'AFF-%')
    GROUP BY l.entite, l.arrete, rr.famille
),
capital AS (
    SELECT l.entite, l.arrete,
           SUM(CASE WHEN e.compte_num LIKE '1021%'
                    THEN e.credit - e.debit ELSE 0 END) AS souscriptions,
           SUM(CASE WHEN e.compte_num LIKE '1022%'
                    THEN e.debit - e.credit ELSE 0 END) AS rachats,
           SUM(CASE WHEN e.compte_num LIKE '129%'
                    THEN e.debit - e.credit ELSE 0 END) AS acomptes_verses,
           SUM(CASE WHEN e.compte_num LIKE '105%'
                    THEN e.credit - e.debit ELSE 0 END)
                                                        AS gain_valorisations,
           -- 06/09/2026 : le resultat determine (120) et le report (11x), pour lire
           -- la distribution de l'exercice precedent dans l'affectation.
           SUM(CASE WHEN e.compte_num LIKE '120%'
                    THEN e.credit - e.debit ELSE 0 END) AS resultat_determine,
           SUM(CASE WHEN e.compte_num LIKE '11%'
                    THEN e.credit - e.debit ELSE 0 END) AS report_a_nouveau
    FROM dbo.v_ecriture_normalisee e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
    GROUP BY l.entite, l.arrete
),
interne AS (
    SELECT f.arrete, f.entite_creditrice AS entite,
           SUM(CASE WHEN f.nature = 'INTERET' THEN f.montant ELSE 0 END)
               AS interets_internes,
           SUM(CASE WHEN f.nature = 'DIVIDENDE' THEN f.montant ELSE 0 END)
               AS dividendes_internes,
           SUM(CASE WHEN f.nature = 'VENTE_IMMEUBLE' THEN f.montant ELSE 0 END)
               AS ventes_internes
    FROM dbo.flux_intragroupe f
    GROUP BY f.arrete, f.entite_creditrice
),
-- L'ELIMINATION DES INTERETS INTERNES, DECIDEE PAR LE CANDIDAT LE 06/09/2026 : le
-- produit chez la mere (compte 724 avec tiers) et la charge chez ses filiales
-- (compte 623 du modele avec la mere pour tiers) se lisent des ECRITURES et se
-- portent sur une meme ligne, qui vaut zero quand la symetrie tient. La version
-- anterieure retirait 4 477 200,00 et ne bouclait que parce que le report a
-- nouveau du jeu oubliait ce meme produit (scripts 67 et 147).
elimination AS (
    SELECT m.entite, m.arrete,
           SUM(CASE WHEN l.entite = m.entite AND e.compte_num LIKE '724%'
                    THEN e.credit - e.debit ELSE 0 END)                       AS produit_mere,
           SUM(CASE WHEN l.entite <> m.entite AND e.compte_num LIKE '623%'
                     AND e.comp_aux_num = m.entite
                    THEN e.debit - e.credit ELSE 0 END)                       AS charge_filiales
    FROM (SELECT DISTINCT entite_mere AS entite, arrete FROM dbo.detention) m
    JOIN dbo.lot_ecritures l
      ON l.arrete = m.arrete AND l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
     AND l.famille <> 'DERIVABLE'
     AND (l.feuille_cote IS NULL OR l.feuille_cote NOT LIKE 'AFF-%')
     AND (l.entite = m.entite OR l.entite IN (SELECT d.entite_fille FROM dbo.detention d
                                               WHERE d.entite_mere = m.entite AND d.arrete = m.arrete))
    JOIN dbo.v_ecriture_normalisee e ON e.lot_id = l.id
    WHERE e.comp_aux_num IS NOT NULL
    GROUP BY m.entite, m.arrete
)
SELECT b.entite, b.arrete, b.arrete_precedent,
       COALESCE(prec.actif_net_reevalue, 0)            AS actif_net_precedent,
       COALESCE(k.souscriptions, 0)                    AS souscriptions,
       -COALESCE(k.rachats, 0)                         AS rachats,
       -- LA DISTRIBUTION : les acomptes de l'exercice (129) et la part du resultat
       -- precedent qui n'a pas ete reportee (resultat N-1 determine, moins ses
       -- acomptes, moins le report a nouveau de N). 06/09/2026.
       -(COALESCE(k.acomptes_verses, 0)
         + CASE WHEN kprec.entite IS NULL OR k.entite IS NULL THEN 0
                ELSE COALESCE(kprec.resultat_determine, 0) - COALESCE(kprec.acomptes_verses, 0)
                     - COALESCE(k.report_a_nouveau, 0) END) AS dividendes_verses,
       COALESCE(corp.montant, 0)                       AS resultat_corporate,
       COALESCE(immo.montant, 0)                       AS resultat_immobilier,
       COALESCE(fin.montant, 0)                        AS resultat_financier,
       COALESCE(pmv.montant, 0)                        AS plus_values_cession,
       -- LA VARIATION, NON LE SOLDE. La balance importee reprend le
       -- cumul du compte 105 : mesure du 04/09/2026, l'ecart de la
       -- rationalisation valait exactement 6 895 952,00, soit la
       -- difference d'estimation deja comptabilisee au 31/12/2024.
       COALESCE(k.gain_valorisations, 0)
         - COALESCE(kprec.gain_valorisations, 0)        AS gain_valorisations,
       -- Les operations internes, retirees du resultat.
       CAST(COALESCE(x.produit_mere, 0) - COALESCE(x.charge_filiales, 0) AS DECIMAL (19,2))
                                                       AS interets_internes_elimines,
       COALESCE(x.produit_mere, 0)                     AS interets_internes_produit_mere,
       COALESCE(x.charge_filiales, 0)                  AS interets_internes_charge_filiales,
       -COALESCE(i.interets_internes, 0)               AS interets_internes_flux_pour_memoire,
       -- LE DIVIDENDE INTERNE N'EST PLUS NEUTRALISE, ET CE N'EST PAS UN
       -- RELACHEMENT. Il l'etait parce que la valeur des titres ne
       -- suivait pas : le produit gonflait l'actif net sans que la
       -- filiale distributrice ne s'appauvrisse dans les comptes. Depuis
       -- les scripts 126 et 127, la filiale comptabilise sa distribution
       -- et le compte 275 de la mere en tient compte : le produit et la
       -- baisse de valeur des titres se compensent d'eux-memes.
       -- Neutraliser en plus retirait le dividende UNE SECONDE FOIS.
       -- Mesure du 05/09/2026 : l'ecart de la rationalisation valait
       -- 194 736,70, exactement le dividende, et il tombe a 0,00 des que
       -- ce poste cesse d'etre soustrait. La colonne demeure, pour que le
       -- montant reste lisible, mais elle ne joue plus dans la somme.
       -COALESCE(i.dividendes_internes, 0)             AS dividendes_internes_pour_memoire,
       -COALESCE(i.ventes_internes, 0)                 AS ventes_internes_pour_memoire,
       -- L'actif net rationalise : la somme des postes.
       CAST(COALESCE(prec.actif_net_reevalue, 0)
          + COALESCE(k.souscriptions, 0) - COALESCE(k.rachats, 0)
          - (COALESCE(k.acomptes_verses, 0)
             + CASE WHEN kprec.entite IS NULL OR k.entite IS NULL THEN 0
                    ELSE COALESCE(kprec.resultat_determine, 0) - COALESCE(kprec.acomptes_verses, 0)
                         - COALESCE(k.report_a_nouveau, 0) END)
          + COALESCE(corp.montant, 0) + COALESCE(immo.montant, 0)
          + COALESCE(fin.montant, 0) + COALESCE(pmv.montant, 0)
          + COALESCE(k.gain_valorisations, 0)
          - COALESCE(kprec.gain_valorisations, 0)
          + COALESCE(x.produit_mere, 0) - COALESCE(x.charge_filiales, 0) AS DECIMAL (19,2))
                                                       AS actif_net_rationalise,
       COALESCE(cur.actif_net_reevalue, 0)             AS actif_net_calcule
FROM bornes b
LEFT JOIN dbo.v_anr_entite cur ON cur.entite = b.entite AND cur.arrete = b.arrete
LEFT JOIN dbo.v_anr_entite prec ON prec.entite = b.entite
                               AND prec.arrete = b.arrete_precedent
LEFT JOIN capital k ON k.entite = b.entite AND k.arrete = b.arrete
LEFT JOIN capital kprec ON kprec.entite = b.entite
                       AND kprec.arrete = b.arrete_precedent
LEFT JOIN resultat corp ON corp.entite = b.entite AND corp.arrete = b.arrete
                       AND corp.famille = 'CORPORATE'
LEFT JOIN resultat immo ON immo.entite = b.entite AND immo.arrete = b.arrete
                       AND immo.famille = 'IMMOBILIER'
LEFT JOIN resultat fin ON fin.entite = b.entite AND fin.arrete = b.arrete
                      AND fin.famille = 'FINANCIER'
LEFT JOIN resultat pmv ON pmv.entite = b.entite AND pmv.arrete = b.arrete
                      AND pmv.famille = 'PMV'
LEFT JOIN interne i ON i.entite = b.entite AND i.arrete = b.arrete
LEFT JOIN elimination x ON x.entite = b.entite AND x.arrete = b.arrete;

GO

