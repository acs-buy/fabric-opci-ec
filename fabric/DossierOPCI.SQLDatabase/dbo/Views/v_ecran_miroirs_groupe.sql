
-- ------------------------------------------------------------------ n° 22 : les ecritures miroir du groupe
-- v_ecriture_miroir_a_passer (possible = 1) et v_controle_miroir_impossible (possible = 0), avec le vehicule.
CREATE   VIEW dbo.v_ecran_miroirs_groupe AS
SELECT pv.vehicule, m.arrete, m.flux_id, m.nature, m.entite, m.compte, m.sens, m.montant_retenu AS montant,
       m.effet_actif_net, m.lecture, CAST(1 AS BIT) AS possible
FROM dbo.v_ecriture_miroir_a_passer m
JOIN dbo.v_perimetre_vehicule pv ON pv.entite = m.entite AND pv.arrete = m.arrete
UNION ALL
SELECT pv.vehicule, i.arrete, NULL, i.nature, i.entite, i.compte, i.sens, i.montant_declare, NULL, i.lecture, CAST(0 AS BIT)
FROM dbo.v_controle_miroir_impossible i
JOIN dbo.v_perimetre_vehicule pv ON pv.entite = i.entite AND pv.arrete = i.arrete;

GO

