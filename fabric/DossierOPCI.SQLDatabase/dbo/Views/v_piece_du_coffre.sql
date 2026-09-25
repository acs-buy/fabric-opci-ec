-- Le compte d'usages par piece, ce que l'ecran affiche en tete.
CREATE   VIEW dbo.v_piece_du_coffre AS
SELECT p.id AS piece_id, p.nom_fichier, p.chemin_coffre, p.empreinte_sha256,
       p.nature, n.libelle AS nature_libelle, n.famille, n.conservation,
       p.periode_debut, p.periode_fin, p.depose_par, p.depose_le,
       (SELECT COUNT(*) FROM dbo.piece_rattachement r WHERE r.piece_id = p.id)
                                                        AS usages,
       (SELECT COUNT(*) FROM dbo.piece_rattachement r
        WHERE r.piece_id = p.id AND r.piece_attendue_id IS NOT NULL)
                                                        AS usages_qualifies,
       (SELECT COUNT(*) FROM dbo.expertise e WHERE e.piece_id = p.id)
                                                        AS expertises_fondees
FROM dbo.piece p
LEFT JOIN dbo.ref_nature_piece n ON n.code = p.nature;

GO

