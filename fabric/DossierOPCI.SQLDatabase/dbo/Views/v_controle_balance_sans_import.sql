-- C29 : une entite du perimetre qui porte une balance sans qu'aucun
-- import ne soit charge. Ce n'est pas une anomalie dans le jeu, dont les
-- balances sont ecrites par script : la vue le mesure pour que l'ecart
-- entre le jeu construit et un dossier reel se lise.
CREATE   VIEW dbo.v_controle_balance_sans_import AS
SELECT entite, arrete, etat_entree, ecritures, imports
FROM dbo.v_perimetre_arrete
WHERE porte_balance = 1 AND ecritures > 0 AND imports_charges = 0;

GO

