
-- --- 3 : les controles -----------------------------------------------
-- C24 : une filiale dont le plan porte encore une identite au plan du
-- modele. ATTENDU zero : une SCI ne tient pas ses comptes au plan de
-- l'article 411-3.
CREATE   VIEW dbo.v_controle_filiale_plan_opci AS
SELECT r.entite, r.compte_entite, r.compte_modele, r.rattache_par
FROM dbo.ref_compte_entite r
JOIN dbo.detention d ON d.entite_fille = r.entite AND d.entite_mere = 'OMEGA-OPCI'
WHERE r.rattache_par LIKE N'SIMULE : jeu de demonstration, identite%';

GO

