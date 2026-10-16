-- 1.4 : les pieces du dossier, colonnes existantes inchangees, 4 colonnes ajoutees en fin.
CREATE   VIEW dbo.v_ecran_pieces_du_dossier AS
SELECT pr.entite, pr.arrete, q.reference AS question, q.enonce AS question_enonce,
       p.id AS piece_id, p.nom_fichier, p.chemin_coffre, p.web_url, p.nature, n.libelle AS nature_libelle, n.famille, n.conservation,
       p.depose_par, p.depose_le, pr.rattache_par, pr.rattache_le, pr.code_actif, pr.piece_attendue_id,
       CASE WHEN q.reference IS NULL THEN 'DOSSIER' ELSE 'QUESTION' END AS portee,
       pr.entite + '|' + CAST(pr.id AS VARCHAR (10)) AS cle_ecran,
       CAST(p.nom_fichier + N' · ' + COALESCE(dbo.fn_date_ecran(pr.arrete), N'sans arrêté') + N' · n° ' + CAST(pr.id AS NVARCHAR (10)) AS NVARCHAR (500)) AS [Pièce],
       dbo.fn_date_ecran(pr.arrete) AS [Arrêté],
       CAST(CASE WHEN r.motif IS NULL THEN N'possible'
                 WHEN r.motif LIKE N'Le dossier de l''arrêté%' THEN N'arrêté verrouillé'
                 WHEN r.motif LIKE N'La pièce fonde la conclusion%' THEN N'fonde une conclusion'
                 -- « La pièce fonde » et son espace font 15 caracteres : la donnee commence au 16e (LEN ignorerait l'espace finale)
                 ELSE N'fonde ' + SUBSTRING(r.motif, 16, CHARINDEX(N' : elle ne se retire', r.motif) - 16) END AS NVARCHAR (60)) AS [Retrait],
       r.motif AS motif_non_retirable
FROM dbo.piece_rattachement pr
JOIN dbo.piece p ON p.id = pr.piece_id
LEFT JOIN dbo.ref_nature_piece n ON n.code = p.nature
LEFT JOIN dbo.ref_question q ON q.id = pr.question_id
OUTER APPLY (SELECT dbo.fn_refus_retrait_piece(pr.entite, pr.id) AS motif) r;

GO

