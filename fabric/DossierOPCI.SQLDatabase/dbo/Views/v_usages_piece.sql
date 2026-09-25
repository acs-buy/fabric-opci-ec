
-- --- 6 : les usages d'une piece, point V16 -------------------------
-- Une piece sert souvent plusieurs fois : un acte d'acquisition fonde le
-- prix de revient ET la surface, un bail fonde le loyer ET la garantie.
-- L'ecran P1 affiche « Usages (n) » et doit les lister.
CREATE   VIEW dbo.v_usages_piece AS
SELECT r.id AS rattachement_id, r.piece_id,
       p.nom_fichier, p.chemin_coffre, p.nature,
       n.libelle                                        AS nature_libelle,
       n.famille, n.conservation,
       p.depose_par, p.depose_le,
       r.entite, r.code_actif, r.question_id, r.arrete,
       r.entite_couverte, r.arrete_couvert, r.piece_attendue_id,
       a.libelle                                        AS exigence,
       a.cycle, a.phase,
       CAST(a.obligatoire AS BIT)                       AS obligatoire,
       a.periodicite,
       q.reference                                      AS question_reference,
       r.rattache_par, r.rattache_le,
       -- La cible du rattachement, en un mot, pour l'ecran.
       CASE WHEN r.code_actif IS NOT NULL THEN 'ACTIF'
            WHEN r.question_id IS NOT NULL THEN 'QUESTION'
            WHEN r.entite IS NOT NULL THEN 'ENTITE'
            ELSE 'INDETERMINEE' END                     AS genre_cible
FROM dbo.piece_rattachement r
JOIN dbo.piece p ON p.id = r.piece_id
LEFT JOIN dbo.ref_nature_piece n ON n.code = p.nature
LEFT JOIN dbo.ref_piece_attendue a ON a.id = r.piece_attendue_id
LEFT JOIN dbo.ref_question q ON q.id = r.question_id;

GO

