

-- ---------------------------------------------------------------------
-- BLOC 7 : dbo.v_cascade_212_5, les 3 effets de la valeur négative.
-- SEULE DANS SON LOT.
-- Article 212-5, quand l'OPCI est engagé à couvrir les pertes et que la
-- valeur de l'entité est négative : titres à zéro, comptes courants
-- totalement dépréciés, provision pour risque filiale pour le solde,
-- contrepartie compte 105.
-- difference_estimation_titres est lue depuis
-- dbo.v_titres_valeur_actuelle (déjà à zéro), non réécrite.
-- Solde à provisionner = opposé de la valeur de détention, moins la
-- valeur comptable du compte courant (engagement résiduel de l'OPCI),
-- borné à zéro par le bas.
-- Les 3 différences d'estimation sont rendues en valeur signée
-- (convention de l'exemple IR4 de l'article).
-- Dépréciation du compte courant : compte 276 (sous-classe 26),
-- contrepartie 1052.
-- Contrepartie de la provision : compte 105 (texte de l'article), et non
-- sa subdivision 1052 comme le critère B18 de la conception le limitait
-- à tort.
-- ATTENDU : une ligne par détention dont la valeur de détention est
-- négative. Zéro ligne est le cas normal d'un groupe sain.
-- Limite : cette vue ne filtre que la condition de valeur négative,
-- aucune donnée du dossier ne portant l'engagement de couverture des
-- pertes (clause statutaire ou conventionnelle) ; le réviseur écarte au
-- vu des statuts une ligne pour une filiale non couverte.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_cascade_212_5 AS
WITH negative AS (
    SELECT
        t.entite_mere                                  AS entite_mere,
        t.entite_fille                                 AS entite_fille,
        t.arrete                                       AS arrete,
        t.valeur_de_detention                          AS valeur_de_detention,
        t.valeur_comptable_titres                      AS valeur_comptable_titres,
        t.valeur_comptable_compte_courant              AS valeur_comptable_compte_courant,
        t.difference_estimation_titres                 AS difference_estimation_titres
    FROM dbo.v_titres_valeur_actuelle AS t
    WHERE t.valeur_de_detention < 0
),
solde AS (
    SELECT
        n.entite_mere                                  AS entite_mere,
        n.entite_fille                                 AS entite_fille,
        n.arrete                                       AS arrete,
        n.valeur_de_detention                          AS valeur_de_detention,
        n.valeur_comptable_titres                      AS valeur_comptable_titres,
        n.valeur_comptable_compte_courant              AS valeur_comptable_compte_courant,
        n.difference_estimation_titres                 AS difference_estimation_titres,
        CAST(0 - n.valeur_de_detention
               - n.valeur_comptable_compte_courant AS DECIMAL (19,2))
                                                       AS solde_a_provisionner
    FROM negative AS n
),
provisionne AS (
    SELECT
        s.entite_mere                                  AS entite_mere,
        s.entite_fille                                 AS entite_fille,
        s.arrete                                       AS arrete,
        s.valeur_de_detention                          AS valeur_de_detention,
        s.valeur_comptable_titres                      AS valeur_comptable_titres,
        s.valeur_comptable_compte_courant              AS valeur_comptable_compte_courant,
        s.difference_estimation_titres                 AS difference_estimation_titres,
        CASE WHEN s.solde_a_provisionner > 0
             THEN s.solde_a_provisionner
             ELSE CAST(0 AS DECIMAL (19,2)) END        AS provision_pour_risque
    FROM solde AS s
)
SELECT
    q.entite_mere                                      AS entite_mere,
    q.entite_fille                                     AS entite_fille,
    q.arrete                                           AS arrete,
    q.valeur_de_detention                              AS valeur_de_detention,
    q.valeur_comptable_titres                          AS valeur_comptable_titres,
    q.valeur_comptable_compte_courant                  AS valeur_comptable_compte_courant,
    q.provision_pour_risque                            AS provision_pour_risque,
    q.difference_estimation_titres                     AS difference_estimation_titres,
    CAST(0 - q.valeur_comptable_compte_courant AS DECIMAL (19,2))
                                                       AS difference_estimation_compte_courant,
    CAST(0 - q.provision_pour_risque AS DECIMAL (19,2))
                                                       AS difference_estimation_provision,
    CAST('275' AS VARCHAR (20))                        AS compte_titres,
    CAST('276' AS VARCHAR (20))                        AS compte_compte_courant,
    CAST('295' AS VARCHAR (20))                        AS compte_provision,
    -- CORRIGE le 04/09/2026, meme motif : la cascade deprecie les titres
    -- (275) et les comptes courants (276), dont la contrepartie est le
    -- compte 105 selon dbo.ref_contrepartie_estimation. Pour le 276,
    -- l'article 213-4 nomme le compte 105 expressement.
    CAST(ce.compte_contrepartie AS VARCHAR (20))       AS compte_contrepartie_estimation,
    -- La provision du compte 295 a pour contrepartie le compte 105,
    -- article 212-5 lu sur piece.
    CAST('105' AS VARCHAR (20))                        AS compte_contrepartie_provision
FROM provisionne AS q
CROSS JOIN dbo.ref_contrepartie_estimation AS ce
WHERE ce.compte_estimation = '275';

GO

