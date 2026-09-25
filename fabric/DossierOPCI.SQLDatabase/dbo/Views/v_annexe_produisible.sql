
-- La meme mesure pour l'annexe entiere, celle que l'ecran L0 lit.
CREATE   VIEW dbo.v_annexe_produisible AS
SELECT c.entite, c.arrete,
       SUM(c.cellules_a_remplir)                   AS cellules_a_remplir,
       SUM(CASE WHEN c.indicatif = 0 THEN c.cellules_a_remplir ELSE 0 END)
                                                   AS bloquantes,
       COUNT(*)                                    AS tableaux,
       CAST(CASE WHEN SUM(CASE WHEN c.indicatif = 0
                               THEN c.cellules_a_remplir ELSE 0 END) = 0
                 THEN 1 ELSE 0 END AS BIT)         AS produisible,
       ISNULL(STRING_AGG(CASE WHEN c.indicatif = 0 AND c.cellules_a_remplir > 0
                              THEN c.article END, ', '), N'')
                                                   AS articles_fautifs,
       CASE WHEN SUM(CASE WHEN c.indicatif = 0
                          THEN c.cellules_a_remplir ELSE 0 END) = 0
            THEN N'l''annexe peut être produite'
            ELSE N'l''annexe ne peut pas être produite : des cellules restent à remplir sur des tableaux au modèle imposé'
            END                                    AS lecture
FROM dbo.v_cellules_a_remplir c
GROUP BY c.entite, c.arrete;

GO

