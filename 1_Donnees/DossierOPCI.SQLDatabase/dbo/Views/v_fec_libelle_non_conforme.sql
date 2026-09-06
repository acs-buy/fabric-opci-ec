

-- BLOC 5 : v_fec_libelle_non_conforme, le refus d'un fichier dont une valeur porte
-- une tabulation, un retour chariot ou un passage à la ligne
--
-- Motif : le premier des 3 caractères trouvés, sur les 11 colonnes de texte du profil fiscal.
-- Périmètre : les mêmes 3 statuts que les vues de projection, aucun filtre de famille.
CREATE   VIEW dbo.v_fec_libelle_non_conforme AS
SELECT
    c.ecriture_id             AS ecriture_id,
    c.lot_id                 AS lot_id,
    c.arrete                 AS arrete,
    c.entite                 AS entite,
    c.famille                AS famille,
    c.colonne                AS colonne,
    CASE WHEN CHARINDEX(CHAR(9),  c.valeur) > 0 THEN 'TABULATION'
         WHEN CHARINDEX(CHAR(13), c.valeur) > 0 THEN 'RETOUR_CHARIOT'
         ELSE 'PASSAGE_LIGNE' END                AS motif,
    CASE WHEN CHARINDEX(CHAR(9),  c.valeur) > 0 THEN CHARINDEX(CHAR(9),  c.valeur)
         WHEN CHARINDEX(CHAR(13), c.valeur) > 0 THEN CHARINDEX(CHAR(13), c.valeur)
         ELSE CHARINDEX(CHAR(10), c.valeur) END  AS position_caractere
FROM (
    SELECT
        e.id                  AS ecriture_id,
        e.lot_id              AS lot_id,
        l.arrete              AS arrete,
        l.entite              AS entite,
        l.famille             AS famille,
        v.colonne             AS colonne,
        v.valeur              AS valeur
    FROM dbo.ecriture e
    JOIN dbo.lot_ecritures l ON l.id = e.lot_id
    CROSS APPLY (VALUES
        ('journal_code',   e.journal_code),
        ('journal_lib',    e.journal_lib),
        ('ecriture_num',   e.ecriture_num),
        ('compte_origine', e.compte_origine),
        ('compte_lib',     e.compte_lib),
        ('comp_aux_num',   e.comp_aux_num),
        ('comp_aux_lib',   e.comp_aux_lib),
        ('piece_ref',      e.piece_ref),
        ('ecriture_lib',   e.ecriture_lib),
        ('ecriture_let',   e.ecriture_let),
        ('id_devise',      e.id_devise)
    ) v (colonne, valeur)
    WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')
) c
WHERE CHARINDEX(CHAR(9),  c.valeur) > 0
   OR CHARINDEX(CHAR(10), c.valeur) > 0
   OR CHARINDEX(CHAR(13), c.valeur) > 0;

GO

