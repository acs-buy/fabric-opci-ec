-- ecran 5, lot 1, script 324 (61_DEPLOIEMENT/generer_e5_324_questions.py) : genere, ne pas modifier a la main.
-- Objet n° 31 : la table des questions de l'etape 3. cle_ecran et v.* restent les 22 colonnes d'avant, aux memes types ;
-- 8 colonnes s'ajoutent, calculees ici, v_question_referentiel restant telle quelle : la cle du cycle ou de la phase
-- (relation au segment), le niveau de programme, le nombre de feuilles qui ont repondu en texte (« 0 feuille »,
-- « 2 feuilles »), les libelles du statut et de l'applicabilite (ref_libelle_valeur, le code a defaut ; A_AUDITER se lit
-- « à valider », decision D7), du modele d'ecriture (« oui », « non »), du niveau (« a remplir » sans niveau) et la date
-- de derniere modification (jj/mm/aaaa, « importe » sans date).
CREATE   VIEW dbo.v_ecran_question_referentiel AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[question_id], 121), N'') AS cle_ecran, v.*,
       CAST(ISNULL(q.cycle, q.phase) AS VARCHAR (10)) AS cycle_ou_phase,
       q.niveau_programme,
       CAST(CAST(ISNULL(f.feuilles, 0) AS NVARCHAR (12)) + CASE WHEN ISNULL(f.feuilles, 0) < 2 THEN N' feuille' ELSE N' feuilles' END
            AS NVARCHAR (30)) AS repondue_dans,
       CAST(ISNULL(ls.libelle, v.statut) AS NVARCHAR (60)) AS statut_libelle,
       CAST(ISNULL(la.libelle, v.applicabilite) AS NVARCHAR (60)) AS applicabilite_libelle,
       CAST(CASE WHEN v.modele_ecriture = 1 THEN N'oui' ELSE N'non' END AS NVARCHAR (3)) AS modele_ecriture_libelle,
       CAST(COALESCE(CAST(q.niveau_programme AS NVARCHAR (9)), N'à remplir') AS NVARCHAR (9)) AS niveau_libelle,
       CAST(COALESCE(CONVERT(NVARCHAR (10), v.modifie_le, 103), N'importé') AS NVARCHAR (10)) AS derniere_modification
FROM dbo.v_question_referentiel v
JOIN dbo.ref_question q ON q.id = v.question_id
OUTER APPLY (SELECT COUNT(DISTINCT fq.cote) AS feuilles FROM dbo.feuille_question fq
             WHERE fq.question_id = v.question_id AND fq.reponse IS NOT NULL) f
LEFT JOIN dbo.ref_libelle_valeur ls ON ls.table_nom = 'ref_question' AND ls.colonne = 'statut' AND ls.valeur = v.statut
LEFT JOIN dbo.ref_libelle_valeur la ON la.table_nom = 'ref_question' AND la.colonne = 'applicabilite'
                                   AND la.valeur = v.applicabilite;

GO

