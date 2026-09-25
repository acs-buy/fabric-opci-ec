

-- BLOC 4 : v_fec_compte_non_conforme, le refus d'un export non conforme avant qu'il soit remis
--
-- MOTIF AMBIGU : compte_origine absent, 2 comptes d'entité ou plus mènent au compte du modèle
-- MOTIF ABSENT : compte_origine absent, aucun compte d'entité ne mène au compte du modèle
-- MOTIF HORS_TROIS_CHIFFRES : les 3 premiers caractères du numéro obtenu ne sont pas 3 chiffres
--
-- Périmètre : les mêmes 3 statuts que les vues de projection.
-- ATTENDU : 0 ligne
CREATE   VIEW dbo.v_fec_compte_non_conforme AS
SELECT
    c.ecriture_id             AS ecriture_id,
    c.lot_id                  AS lot_id,
    c.arrete                  AS arrete,
    c.entite                  AS entite,
    c.famille                 AS famille,
    c.compte_origine          AS compte_origine,
    c.compte_modele           AS compte_modele,
    c.candidats               AS rattachements_candidats,
    c.champ_cinq              AS champ_cinq,
    CASE WHEN c.compte_origine IS NULL AND c.candidats > 1 THEN 'AMBIGU'
         WHEN c.champ_cinq IS NULL                         THEN 'ABSENT'
         ELSE 'HORS_TROIS_CHIFFRES' END                    AS motif
FROM (
    SELECT
        e.id                  AS ecriture_id,
        e.lot_id              AS lot_id,
        l.arrete              AS arrete,
        l.entite              AS entite,
        l.famille             AS famille,
        e.compte_origine      AS compte_origine,
        e.compte_num          AS compte_modele,
        (SELECT COUNT(*)
           FROM dbo.ref_compte_entite r
          WHERE r.entite = l.entite
            AND r.compte_modele = e.compte_num) AS candidats,
        COALESCE(e.compte_origine,
                 (SELECT MAX(r.compte_entite)
                    FROM dbo.ref_compte_entite r
                   WHERE r.entite = l.entite
                     AND r.compte_modele = e.compte_num
                  HAVING COUNT(*) = 1)) AS champ_cinq
    FROM dbo.ecriture e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
) c
WHERE c.champ_cinq IS NULL
   OR c.champ_cinq NOT LIKE '[0-9][0-9][0-9]%';

GO

