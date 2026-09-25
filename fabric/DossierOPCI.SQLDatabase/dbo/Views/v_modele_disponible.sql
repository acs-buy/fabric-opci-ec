

-- --- 5 : V6, le modele d'ecriture disponible par question ------------
-- La colonne « Modele » de l'ecran A est un oui ou non, lu d'une vue sur
-- dbo.modele_ecriture, complement 8 du § 7.13. La vue rend la reponse
-- pour TOUTE question, y compris celle qui n'a pas de modele : une
-- jointure externe sur la table des modeles laisserait la colonne vide au
-- lieu de rendre « non ».
CREATE   VIEW dbo.v_modele_disponible AS
SELECT q.id                               AS question_id,
       q.reference,
       q.cycle, q.phase,
       CAST(CASE WHEN m.lignes > 0 THEN 1 ELSE 0 END AS BIT)
                                          AS modele_disponible,
       COALESCE(m.lignes, 0)              AS lignes_du_modele,
       m.comptes,
       -- Le modele de feuille de travail est un autre objet : le fichier
       -- que la question ouvre. La colonne « Feuille de travail » de
       -- l'ecran A le lit, et la confusion des 2 est facile.
       CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.ref_question_modele rqm
                              WHERE rqm.question_id = q.id)
                 THEN 1 ELSE 0 END AS BIT) AS modele_feuille_disponible
FROM dbo.ref_question q
OUTER APPLY (
    SELECT COUNT(*) AS lignes,
           STRING_AGG(CAST(e.compte_num AS NVARCHAR (20)), N', ')
               WITHIN GROUP (ORDER BY e.ordre) AS comptes
    FROM dbo.modele_ecriture e
    WHERE e.question_id = q.id
) AS m;

GO

