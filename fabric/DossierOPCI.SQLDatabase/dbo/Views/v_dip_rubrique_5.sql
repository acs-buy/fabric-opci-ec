
-- 5. « Les mouvements du portefeuille dans la période » : le nombre de mouvements, et chacun.
CREATE   VIEW dbo.v_dip_rubrique_5 AS
SELECT g.entite, g.arrete, g.cle_arrete,
       COUNT(m.code_actif) OVER (PARTITION BY g.entite, g.arrete) AS nombre_mouvements,
       m.code_actif, m.nature, m.date_mouvement, m.montant,
       CAST(CASE WHEN m.code_actif IS NULL THEN N'à remplir' END AS NVARCHAR (20)) AS etat
FROM dbo.v_dip_arrete g
LEFT JOIN dbo.v_client_mouvement_actif m ON m.entite = g.entite AND m.arrete = g.arrete;

GO

