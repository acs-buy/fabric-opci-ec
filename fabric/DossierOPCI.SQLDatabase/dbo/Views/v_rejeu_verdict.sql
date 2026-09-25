
-- --- 6 : le verdict du rejeu, un arrete contre un autre ---------------
-- ATTENDU sur un rejeu du profil source : ecart_max a zero, comptes en
-- ecart a zero. Le seuil de concordance de 100 euros du protocole ne
-- s'applique pas ici : un rejeu de fichier est une egalite exacte.
CREATE   VIEW dbo.v_rejeu_verdict AS
SELECT entite, arrete_origine, arrete_rejeu,
       COUNT(*)                                             AS comptes,
       SUM(CASE WHEN ecart_profil_source <> 0 THEN 1 ELSE 0 END)
                                                            AS comptes_en_ecart_source,
       CAST(MAX(ABS(ecart_profil_source)) AS DECIMAL (19,2)) AS ecart_max_source,
       SUM(CASE WHEN ecart_profil_avec_ajustements <> 0 THEN 1 ELSE 0 END)
                                                            AS comptes_en_ecart_avec_ajustements,
       CAST(MAX(ABS(ecart_profil_avec_ajustements)) AS DECIMAL (19,2))
                                                            AS ecart_max_avec_ajustements
FROM dbo.v_rejeu_concordance
GROUP BY entite, arrete_origine, arrete_rejeu;

GO

