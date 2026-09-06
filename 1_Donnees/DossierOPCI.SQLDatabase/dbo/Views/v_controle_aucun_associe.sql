
-- C50 : aucune connexion ne porte le role d'associe. La base serait
-- alors en lecture seule sur tous ses referentiels, y compris pour les
-- semis. ATTENDU zero.
CREATE   VIEW dbo.v_controle_aucun_associe AS
SELECT COUNT(*) AS associes_avec_connexion
FROM dbo.role_mission
WHERE role = 'ASSOCIE' AND au IS NULL AND connexion IS NOT NULL
HAVING COUNT(*) = 0;

GO

