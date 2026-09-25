CREATE VIEW dbo.v_ecran_synthese AS
WITH n AS (
    SELECT
        pieces_attendues = (SELECT COUNT(*) FROM dbo.ref_piece_attendue),
        pieces_deposees  = (SELECT COUNT(*) FROM dbo.piece),
        vises            = (SELECT SUM(vises) FROM dbo.v_ecran_supervision_cycle),
        renvoyes         = (SELECT SUM(renvoyes) FROM dbo.v_ecran_supervision_cycle),
        refus            = (SELECT COUNT(*) FROM dbo.v_ecran_journal_visa WHERE issue = 'REFUSE'),
        -- PERIMETRE RECTIFIE LE 12/09/2026, APRES LECTURE DE LA CAPTURE DE L'ECRAN POSE.
        -- Ces 3 sommes ne portaient aucun filtre : 60 lignes, 4 arretes et 13 entites. Elles
        -- s'affichaient sous un bandeau annoncant « OMEGA-OPCI, arrete du 31/12/2025 », et la
        -- valeur comptable de 797 976 400,00 comptait 4 fois le meme patrimoine. C'est le piege
        -- que la ligne des parts evite 20 lignes plus bas, et je n'avais pas vu que les
        -- differences le presentaient aussi. Elles portent desormais sur l'arrete courant du
        -- vehicule porteur, ce qui les met d'accord avec la carte DIFF_COMPTABILISEE, dont la
        -- reference vaut deja 12 815 149,24 sur ce seul arrete.
        diff_total       = (SELECT SUM(d.difference_estimation) FROM dbo.v_differences_synthese d
                            WHERE d.entite = (SELECT TOP 1 v.entite FROM dbo.v_ecran_valeur_liquidative v
                                              WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)
                              AND d.arrete = (SELECT TOP 1 v.arrete FROM dbo.v_ecran_valeur_liquidative v
                                              WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)),
        val_comptable    = (SELECT SUM(d.valeur_comptable) FROM dbo.v_differences_synthese d
                            WHERE d.entite = (SELECT TOP 1 v.entite FROM dbo.v_ecran_valeur_liquidative v
                                              WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)
                              AND d.arrete = (SELECT TOP 1 v.arrete FROM dbo.v_ecran_valeur_liquidative v
                                              WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)),
        val_actuelle     = (SELECT SUM(d.valeur_actuelle) FROM dbo.v_differences_synthese d
                            WHERE d.entite = (SELECT TOP 1 v.entite FROM dbo.v_ecran_valeur_liquidative v
                                              WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)
                              AND d.arrete = (SELECT TOP 1 v.arrete FROM dbo.v_ecran_valeur_liquidative v
                                              WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC)),
        -- Les parts de l'arrete le plus recent du vehicule porteur, et non une somme : additionner
        -- les parts de 4 arretes du meme vehicule compterait 4 fois le meme capital.
        parts            = (SELECT TOP 1 v.nombre_parts FROM dbo.v_ecran_valeur_liquidative v
                            WHERE v.ecart IS NOT NULL ORDER BY v.arrete DESC),
        ref_associe      = (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE qui_tient = 'ASSOCIE'),
        ref_base         = (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE qui_tient = 'BASE'),
        ref_reviseur     = (SELECT COUNT(*) FROM dbo.v_ecran_inventaire_referentiel WHERE qui_tient = 'REVISEUR'),
        ref_lignes       = (SELECT SUM(lignes) FROM dbo.v_ecran_inventaire_referentiel),
        ref_lignes_top8  = (SELECT SUM(lignes) FROM (SELECT TOP 8 lignes
                            FROM dbo.v_ecran_inventaire_referentiel ORDER BY lignes DESC) t)
)
SELECT CAST(s.parcours AS varchar(40))   AS parcours,
       CAST(s.panneau  AS varchar(40))   AS panneau,
       CAST(s.code     AS varchar(40))   AS code,
       CAST(s.valeur_num AS decimal(19, 2)) AS valeur_num,
       CAST(s.libelle  AS nvarchar(160)) AS libelle,
       CAST(s.ordre    AS int)           AS ordre,
       -- SUR QUOI CHAQUE LIGNE PORTE, ajoute le 12/09/2026 pour la meme raison que
       -- reference_nature sur les cartes : une legende sous un bandeau filtre laisse croire
       -- qu'elle suit le filtre, et rien ne disait laquelle le fait.
       -- ARRETE_COURANT : la ligne porte sur l'arrete courant du vehicule porteur.
       -- DOSSIER : la ligne porte sur tout le dossier, quels que soient l'entite et l'arrete.
       -- REFERENTIEL : la ligne porte sur un referentiel, qui n'a ni entite ni arrete.
       CAST(CASE
            WHEN s.panneau IN ('DIFFERENCES_PAR_FAMILLE', 'VL') THEN 'ARRETE_COURANT'
            WHEN s.panneau IN ('ETAT_DU_RELEVE', 'LES_8_PLUS_FOURNIS') THEN 'REFERENTIEL'
            WHEN s.code = 'PIECES_ATTENDUES' THEN 'REFERENTIEL'
            ELSE 'DOSSIER' END AS varchar(16))  AS portee
FROM n
CROSS APPLY (VALUES
    ('Client-et-collecte',      'PIECES_PAR_ETAT', 'PIECES_ATTENDUES', n.pieces_attendues, N'pièces attendues au référentiel', 1),
    ('Client-et-collecte',      'PIECES_PAR_ETAT', 'PIECES_DEPOSEES',  n.pieces_deposees,  N'pièces déposées au coffre',      2),

    ('Revision-et-supervision', 'ETAT_DES_CYCLES', 'VISES',            n.vises,            N'visés',                          1),
    ('Revision-et-supervision', 'ETAT_DES_CYCLES', 'RENVOYES',         n.renvoyes,         N'renvoyé',                        2),
    ('Revision-et-supervision', 'ETAT_DES_CYCLES', 'REFUS',            n.refus,            N'refus',                          3),

    ('Valorisation', 'DIFFERENCES_PAR_FAMILLE', 'DIFF_TOTAL',    n.diff_total,    N'total des différences d''estimation', 1),
    ('Valorisation', 'DIFFERENCES_PAR_FAMILLE', 'VAL_COMPTABLE', n.val_comptable, N'valeur comptable',                    2),
    ('Valorisation', 'DIFFERENCES_PAR_FAMILLE', 'VAL_ACTUELLE',  n.val_actuelle,  N'valeur actuelle',                     3),

    ('Arrete-et-livrables', 'VL',     'PARTS',       n.parts, N'parts en circulation',                                    1),
    ('Arrete-et-livrables', 'VL',     'SOURCE',      NULL,    N'source simulée : registre des porteurs du cas construit', 2),
    ('Arrete-et-livrables', 'RATIOS', 'SOURCE',      NULL,    N'seuils lus au texte, les 4 calculs portent la mention à valider', 1),

    ('Referentiels', 'ETAT_DU_RELEVE',    'TENUS_ASSOCIE',  n.ref_associe,     N'tenus par l''associé',   1),
    ('Referentiels', 'ETAT_DU_RELEVE',    'TENUS_BASE',     n.ref_base,        N'par la base',            2),
    ('Referentiels', 'ETAT_DU_RELEVE',    'TENUS_REVISEUR', n.ref_reviseur,    N'par le réviseur',        3),
    ('Referentiels', 'LES_8_PLUS_FOURNIS','LIGNES_TOP8',    n.ref_lignes_top8, N'lignes portées par les 8', 1),
    ('Referentiels', 'LES_8_PLUS_FOURNIS','LIGNES_TOTAL',   n.ref_lignes,      N'lignes au total',          2)
) AS s(parcours, panneau, code, valeur_num, libelle, ordre);

GO

