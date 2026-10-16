
-- ------------------------------------------------------------------ n° 18 : vehicule et ordre de la cascade
-- vehicule : le vehicule dont le perimetre porte la filiale a l'arrete (v_perimetre_vehicule, le vehicule lui-meme exclu).
-- ordre : bloc CAPITAUX puis ACTIFS, puis reference ; rang commun a toutes les entites (une reference n'est que d'un bloc).
CREATE   VIEW dbo.v_ecran_anr_filiale_detail AS
SELECT ISNULL(CONVERT(NVARCHAR (200), v.[entite], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[arrete], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[bloc], 121), N'') + N'|' + ISNULL(CONVERT(NVARCHAR (200), v.[reference], 121), N'') AS cle_ecran, v.*,
       pv.vehicule,
       CAST(DENSE_RANK() OVER (ORDER BY CASE v.bloc WHEN 'CAPITAUX' THEN 1 WHEN 'ACTIFS' THEN 2 ELSE 3 END, v.reference) AS INT) AS ordre
FROM dbo.v_anr_filiale_detail v
LEFT JOIN dbo.v_perimetre_vehicule pv ON pv.entite = v.entite AND pv.arrete = v.arrete AND pv.vehicule <> v.entite;

GO

