
-- --- 7 : la condition 2, conclue et non plus semee -------------------
-- LA REGLE : la condition 2 est satisfaite quand AUCUN immeuble de la
-- societe n'est a qualifier. Une societe qui ne detient aucun immeuble
-- la satisfait par vacuite, et la vue le dit au lieu de le taire : le
-- texte pose une condition SUR les immeubles a l'actif, et l'absence
-- d'immeuble n'est pas un manquement.
CREATE   VIEW dbo.v_condition_2_immeubles AS
-- LA LIGNE FANTOME DE LA JOINTURE EXTERNE. Pour une societe sans
-- immeuble, la jointure externe rend UNE ligne dont toutes les colonnes
-- sont nulles. COUNT l'ignore, mais une somme conditionnelle la compte :
-- ecrite sans garde, elle rendait « 1 immeuble a qualifier » pour une
-- societe qui n'en detient aucun. Chaque somme teste donc d'abord
-- l'existence de la ligne. Le decompte lui-meme est une somme gardee
-- et non un COUNT, qui signalait a chaque appel qu'il ecartait des
-- valeurs nulles : un avertissement repete a chaque execution finit
-- par masquer ceux qui portent quelque chose.
SELECT e.entite_mere, e.entite_fille,
       SUM(CASE WHEN c.code_actif IS NULL THEN 0 ELSE 1 END)   AS immeubles,
       SUM(CASE WHEN c.code_actif IS NULL THEN 0
                WHEN c.conforme = 1 THEN 1 ELSE 0 END)         AS conformes,
       SUM(CASE WHEN c.code_actif IS NULL THEN 0
                WHEN c.conforme = 1 THEN 0 ELSE 1 END)         AS a_qualifier,
       CAST(CASE WHEN SUM(CASE WHEN c.code_actif IS NULL THEN 0
                              WHEN c.conforme = 1 THEN 0 ELSE 1 END) = 0
                 THEN 1 ELSE 0 END AS BIT)                     AS condition_2,
       CASE WHEN SUM(CASE WHEN c.code_actif IS NULL THEN 0 ELSE 1 END) = 0
            THEN N'satisfaite sans objet : la société ne détient aucun immeuble, la condition ne peut pas être enfreinte'
            WHEN SUM(CASE WHEN c.code_actif IS NULL THEN 0
                          WHEN c.conforme = 1 THEN 0 ELSE 1 END) = 0
            THEN N'satisfaite : les ' + CAST(SUM(CASE WHEN c.code_actif IS NULL THEN 0 ELSE 1 END) AS NVARCHAR (6))
                 + N' immeubles relèvent des articles R. 214-81 et R. 214-82'
            ELSE N'non satisfaite : '
                 + CAST(SUM(CASE WHEN c.code_actif IS NULL THEN 0
                                 WHEN c.conforme = 1 THEN 0 ELSE 1 END)
                        AS NVARCHAR (6))
                 + N' immeuble(s) restent à qualifier'
            END                                                AS lecture
FROM dbo.eligibilite_participation e
LEFT JOIN dbo.v_conformite_immeuble c
       ON c.entite_detentrice = e.entite_fille
GROUP BY e.entite_mere, e.entite_fille;

GO

