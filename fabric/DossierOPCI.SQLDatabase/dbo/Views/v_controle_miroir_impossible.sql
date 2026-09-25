
-- --- 3 : le controle -------------------------------------------------
-- C78 : un flux dont le cote manquant ne peut PAS etre passe. Un pret
-- sans compte de tresorerie crediteur en est le cas : rien ne dit d'ou
-- viendrait le reclassement, et la procedure l'ecarte plutot que
-- d'inventer une contrepartie.
CREATE   VIEW dbo.v_controle_miroir_impossible AS
SELECT arrete, nature, entite, compte, sens, montant_declare, lecture
FROM dbo.v_ecriture_miroir_a_passer
WHERE (nature = 'DIVIDENDE' AND compte_tresorerie IS NULL)
   OR montant_retenu <= 0;

GO

