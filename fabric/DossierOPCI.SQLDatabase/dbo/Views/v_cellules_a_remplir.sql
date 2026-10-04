

-- 4. UNE RUBRIQUE NE PORTE AUCUNE CELLULE : v_cellules_a_remplir ne la compte plus. L'article 331-1, dont la ligne
-- de principe est une rubrique, n'a donc aucune cellule.
CREATE   VIEW dbo.v_cellules_a_remplir AS
SELECT m.entite, m.arrete, m.article, m.tableau,
       CAST(ISNULL(t.indicatif, 0) AS BIT)         AS indicatif,
       SUM(CASE WHEN m.a_saisir = 1 THEN 1 ELSE 0 END) AS cellules_a_remplir,
       COUNT(*)                                    AS cellules,
       CASE WHEN SUM(CASE WHEN m.a_saisir = 1 THEN 1 ELSE 0 END) = 0
            THEN N'complet'
            WHEN ISNULL(t.indicatif, 0) = 1
            THEN N'incomplet, modèle indicatif : le document peut être produit'
            ELSE N'incomplet, modèle imposé : le document ne peut pas être produit'
            END                                    AS lecture
FROM dbo.v_ligne_annexe_montant m
LEFT JOIN dbo.ref_tableau_annexe t ON t.article = m.article
WHERE m.type_ligne <> 'RUBRIQUE'
GROUP BY m.entite, m.arrete, m.article, m.tableau, t.indicatif;

GO

