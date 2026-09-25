
-- --- depuis 63_SQL/42_valorisation_participations.sql : v_titres_valeur_actuelle ---
-- ---------------------------------------------------------------------
-- BLOC 6 : dbo.v_titres_valeur_actuelle, la valeur actuelle des titres
-- d'une filiale et sa différence d'estimation. SEULE DANS SON LOT.
-- Calcul en 3 temps nommés : detenu ramène l'actif net réévalué à
-- DECIMAL (19,2) ; valorise multiplie par la quote-part et ramène le
-- produit à DECIMAL (19,2) ; retenu applique l'article 212-5 (valeur
-- négative à zéro). Conversion nécessaire, cf. l'en-tête (précision
-- décimale).
-- Lues par le compte auxiliaire (convention de l'en-tête) : titres =
-- comptes 252, 254, 256, 258 (série 25) ; compte courant = compte 266.
-- Lots DERIVABLE écartés du portage : la valeur comptable est celle
-- d'avant valorisation.
-- Jointure interne sur l'actif net réévalué : une filiale sans écriture
-- validée à l'arrêté n'a pas d'actif net réévalué, distinct d'un total nul.
-- Jointure externe sur le portage : une filiale sans titre comptabilisé
-- au bilan de la mère (apport en nature non encore comptabilisé) a une
-- valeur actuelle dont la différence d'estimation vaut la valeur entière.
-- Différence d'estimation sur titres comptabilisée au 275 (bloc 4),
-- contrepartie 1052 (marqueur classe 2, qui couvre la sous-classe 25
-- sans la nommer). Point ouvert : une subdivision 1054 serait plus
-- précise, non tranchée ici.
-- ATTENDU : une ligne par détention dont la filiale a un actif net
-- réévalué à l'arrêté.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_titres_valeur_actuelle AS
WITH portage AS (
    SELECT
        l.entite                AS entite_mere,
        e.comp_aux_num          AS entite_fille,
        l.arrete                AS arrete,
        SUM(CASE WHEN e.compte_num LIKE '25%'
                 THEN e.debit - e.credit ELSE 0 END)   AS valeur_comptable_titres,
        SUM(CASE WHEN e.compte_num = '266'
                 THEN e.debit - e.credit ELSE 0 END)   AS valeur_comptable_compte_courant
    FROM dbo.v_ecriture_normalisee AS e
    INNER JOIN dbo.lot_ecritures AS l
        ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
      AND l.famille <> 'DERIVABLE'
      AND e.comp_aux_num IS NOT NULL
      AND (e.compte_num LIKE '25%' OR e.compte_num = '266')
    GROUP BY l.entite, e.comp_aux_num, l.arrete
),
detenu AS (
    SELECT
        d.entite_mere                                  AS entite_mere,
        d.entite_fille                                 AS entite_fille,
        d.arrete                                       AS arrete,
        d.quote_part                                   AS quote_part,
        CAST(v.actif_net_reevalue AS DECIMAL (19,2))   AS actif_net_reevalue
    FROM dbo.detention AS d
    INNER JOIN dbo.v_anr_filiale AS v
        ON v.entite = d.entite_fille
       AND v.arrete = d.arrete
),
valorise AS (
    SELECT
        t.entite_mere                                  AS entite_mere,
        t.entite_fille                                 AS entite_fille,
        t.arrete                                       AS arrete,
        t.quote_part                                   AS quote_part,
        t.actif_net_reevalue                           AS actif_net_reevalue,
        CAST(t.actif_net_reevalue * t.quote_part AS DECIMAL (19,2))
                                                       AS valeur_de_detention
    FROM detenu AS t
),
retenu AS (
    SELECT
        w.entite_mere                                  AS entite_mere,
        w.entite_fille                                 AS entite_fille,
        w.arrete                                       AS arrete,
        w.quote_part                                   AS quote_part,
        w.actif_net_reevalue                           AS actif_net_reevalue,
        w.valeur_de_detention                          AS valeur_de_detention,
        CASE WHEN w.valeur_de_detention < 0
             THEN CAST(0 AS DECIMAL (19,2))
             ELSE w.valeur_de_detention END            AS valeur_actuelle_titres
    FROM valorise AS w
)
SELECT
    r.entite_mere                                      AS entite_mere,
    r.entite_fille                                     AS entite_fille,
    r.arrete                                           AS arrete,
    r.quote_part                                       AS quote_part,
    r.actif_net_reevalue                               AS actif_net_reevalue,
    r.valeur_de_detention                              AS valeur_de_detention,
    r.valeur_actuelle_titres                           AS valeur_actuelle_titres,
    CAST(COALESCE(p.valeur_comptable_titres, 0) AS DECIMAL (19,2))
                                                       AS valeur_comptable_titres,
    CAST(COALESCE(p.valeur_comptable_compte_courant, 0) AS DECIMAL (19,2))
                                                       AS valeur_comptable_compte_courant,
    CAST(r.valeur_actuelle_titres
       - COALESCE(p.valeur_comptable_titres, 0) AS DECIMAL (19,2))
                                                       AS difference_estimation_titres,
    CAST('275' AS VARCHAR (20))                        AS compte_difference_estimation,
    -- CORRIGE le 04/09/2026. La contrepartie se LIT dans
    -- dbo.ref_contrepartie_estimation, elle ne se code pas en dur : pour
    -- le compte 275, c'est le compte 105 et non le 1052. Le libelle du
    -- 1052, lu sur piece dans le plan de comptes de l'article 411-3, vise
    -- « les comptes d'immeubles en cours, construits ou acquis et des
    -- autres droits reels (classe 2) », et celui du 1053 « les depots et
    -- instruments financiers ». Aucun des 2 ne couvre les titres. Le
    -- script 68 a passe ses ecritures au 105, cette vue rendait 1052 : un
    -- ecran qui l'aurait lue aurait ecrit au mauvais compte.
    CAST(ce.compte_contrepartie AS VARCHAR (20))       AS compte_contrepartie
FROM retenu AS r
CROSS JOIN dbo.ref_contrepartie_estimation AS ce
LEFT JOIN portage AS p
    ON p.entite_mere = r.entite_mere
   AND p.entite_fille = r.entite_fille
   AND p.arrete = r.arrete
WHERE ce.compte_estimation = '275';

GO

