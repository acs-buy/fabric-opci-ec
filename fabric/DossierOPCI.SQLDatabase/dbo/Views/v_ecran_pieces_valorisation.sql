
-- ------------------------------------------------------------------ n° 19 : les pieces du vehicule et de ses filiales
-- Un rapport depose sous une filiale se propose pour l'actif de toute entite du perimetre. arrete = periode_fin.
CREATE   VIEW dbo.v_ecran_pieces_valorisation AS
SELECT pv.vehicule, CONVERT(VARCHAR (10), p.periode_fin, 23) AS arrete, p.entite, p.id AS piece_id, p.nom_fichier,
       p.nature, p.web_url, pv.vehicule + '|' + CAST(p.id AS VARCHAR (12)) AS cle_ecran
FROM dbo.piece p
JOIN dbo.v_perimetre_vehicule pv ON pv.entite = p.entite AND pv.arrete = CONVERT(VARCHAR (10), p.periode_fin, 23);

GO

