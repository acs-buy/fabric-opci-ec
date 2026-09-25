
-- LE PERIMETRE DU CONTEXTE, la vue que toutes les vues d'ecran joindront.
-- Elle rend les entites du groupe du vehicule choisi et l'arrete choisi. Vide tant que le reviseur
-- n'a rien choisi : un ecran sans contexte ne montre rien, ce qui vaut mieux qu'un ecran qui
-- montre le dossier d'un autre.
CREATE   VIEW dbo.v_mon_perimetre AS
SELECT p.entite, c.arrete, c.vehicule
FROM dbo.contexte_reviseur c
JOIN dbo.v_perimetre_groupe p ON p.vehicule = c.vehicule
WHERE c.utilisateur = SESSION_USER AND c.vehicule IS NOT NULL AND c.arrete IS NOT NULL;

GO

