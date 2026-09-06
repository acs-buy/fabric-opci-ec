
-- Le controle de troncature suit le pas calcule.
CREATE   VIEW dbo.v_controle_montant_tronque AS
SELECT p.cle_arrete, p.obligation_minimale, p.plafond_distribuable, p.pas,
       CAST(p.intervalle / p.pas AS DECIMAL (19,2)) AS pas_necessaires
FROM dbo.v_pas_simulable p
WHERE p.plafond_distribuable >= p.obligation_minimale
  AND p.intervalle / p.pas > 4095;

GO

