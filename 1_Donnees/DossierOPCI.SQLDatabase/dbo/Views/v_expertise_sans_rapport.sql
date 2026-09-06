

-- ---------------------------------------------------------------------
-- BLOC 2 : v_expertise_sans_rapport. Le refus d'une valeur d'expertise
-- dépourvue de son rapport. SEULE DANS SON LOT.
-- ATTENDU : 0 ligne pour l'arrêté traité est la condition du calcul de
-- valorisation.
-- ---------------------------------------------------------------------
CREATE   VIEW dbo.v_expertise_sans_rapport AS
SELECT
    c.expertise_id              AS expertise_id,
    c.code_actif                AS code_actif,
    c.entite_detentrice         AS entite_detentrice,
    c.date_valeur               AS date_valeur,
    c.valeur_actuelle           AS valeur_actuelle,
    c.piece_id                  AS piece_id,
    c.rattachements_de_la_piece AS rattachements_de_la_piece,
    c.pieces_candidates         AS pieces_candidates,
    CASE WHEN c.piece_id IS NULL THEN 'PIECE_ABSENTE'
         ELSE 'RATTACHEMENT_ABSENT' END AS motif
FROM (
    SELECT
        e.id                AS expertise_id,
        e.code_actif        AS code_actif,
        a.entite_detentrice AS entite_detentrice,
        e.date_valeur       AS date_valeur,
        e.valeur_actuelle   AS valeur_actuelle,
        e.piece_id          AS piece_id,
        (SELECT COUNT(*)
           FROM dbo.piece_rattachement r
          WHERE r.piece_id = e.piece_id
            AND (r.code_actif = e.code_actif
                 OR r.entite = a.entite_detentrice)) AS rattachements_de_la_piece,
        (SELECT COUNT(*)
           FROM dbo.piece_rattachement r
          WHERE r.code_actif = e.code_actif
             OR r.entite = a.entite_detentrice)      AS pieces_candidates
    FROM dbo.expertise e
    JOIN dbo.actif a ON a.code = e.code_actif
) c
WHERE c.piece_id IS NULL
   OR c.rattachements_de_la_piece = 0;

GO

