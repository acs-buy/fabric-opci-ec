
-- 4. les pieces du dossier, sous le questionnaire ---------------------------------------------------------
-- Regle du candidat, 19/09/2026 : « en dessous du questionnaire, on va pouvoir lister toutes les pieces
-- justificatives avec leur nature et leur date de depot, et peut-etre la personne qui les a deposees »,
-- et « quand on rouvre le questionnaire, voir que la question etait liee a telle piece ».
-- Une ligne par rattachement d'une piece a une entite ; la question par sa REFERENCE lisible.
-- Demandee par Fabric IQ le 19/09/2026 : filtrable par entite dans un seul visuel, sans joindre 2 vues.
CREATE   VIEW dbo.v_ecran_pieces_du_dossier AS
SELECT pr.entite, pr.arrete, q.reference AS question, q.enonce AS question_enonce,
       p.id AS piece_id, p.nom_fichier, p.chemin_coffre, p.nature, n.libelle AS nature_libelle, n.famille, n.conservation,
       p.depose_par, p.depose_le, pr.rattache_par, pr.rattache_le, pr.code_actif, pr.piece_attendue_id,
       CASE WHEN q.reference IS NULL THEN 'DOSSIER' ELSE 'QUESTION' END AS portee,
       pr.entite + '|' + CAST(pr.id AS VARCHAR (10)) AS cle_ecran
FROM dbo.piece_rattachement pr
JOIN dbo.piece p ON p.id = pr.piece_id
LEFT JOIN dbo.ref_nature_piece n ON n.code = p.nature
LEFT JOIN dbo.ref_question q ON q.id = pr.question_id;

GO

