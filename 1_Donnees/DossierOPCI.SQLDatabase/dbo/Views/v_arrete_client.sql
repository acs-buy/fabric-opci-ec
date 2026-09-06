
-- --- 2 : la dimension d'arrete du client, gardee par le visa -------------
-- Memes colonnes qu'au script 64, plus le visa qui ouvre la porte.
CREATE   VIEW dbo.v_arrete_client AS
SELECT a.entite + '|' + a.arrete AS cle_arrete,
       a.entite, a.arrete, a.type_arrete, a.exercice, a.date_arrete,
       c.visa_id AS visa_cloture_id, c.decide_par AS cloture_visee_par,
       c.decide_le AS cloture_visee_le
FROM dbo.arrete_mission a
JOIN dbo.v_visa_cloture_courant c ON c.entite = a.entite AND c.arrete = a.arrete
JOIN dbo.ref_arrete r ON r.entite = a.entite AND r.arrete = a.arrete
WHERE a.exercice IS NOT NULL
  AND a.date_arrete IS NOT NULL
  AND c.decision = 'VISE'
  AND r.porte_balance = 1;

GO

