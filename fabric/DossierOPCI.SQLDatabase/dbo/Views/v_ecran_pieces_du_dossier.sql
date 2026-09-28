
-- LES PIECES DU DOSSIER, AVEC LEUR LIEN. Ajout du 28/09/2026 : chaque fiche porte l'adresse
-- SharePoint de son fichier, web_url, et l'ecran l'ouvre au clic. chemin_coffre reste : c'est le
-- chemin du meme fichier vu du coffre, par son raccourci.
CREATE   VIEW dbo.v_ecran_pieces_du_dossier AS
SELECT pr.entite, pr.arrete, q.reference AS question, q.enonce AS question_enonce,
       p.id AS piece_id, p.nom_fichier, p.chemin_coffre, p.web_url, p.nature, n.libelle AS nature_libelle, n.famille, n.conservation,
       p.depose_par, p.depose_le, pr.rattache_par, pr.rattache_le, pr.code_actif, pr.piece_attendue_id,
       CASE WHEN q.reference IS NULL THEN 'DOSSIER' ELSE 'QUESTION' END AS portee,
       pr.entite + '|' + CAST(pr.id AS VARCHAR (10)) AS cle_ecran
FROM dbo.piece_rattachement pr
JOIN dbo.piece p ON p.id = pr.piece_id
LEFT JOIN dbo.ref_nature_piece n ON n.code = p.nature
LEFT JOIN dbo.ref_question q ON q.id = pr.question_id;

GO

