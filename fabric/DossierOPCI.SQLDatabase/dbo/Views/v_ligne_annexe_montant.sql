
CREATE   VIEW dbo.v_ligne_annexe_montant AS
SELECT article, code, libelle, niveau, type_ligne, signe, ordre, renvoi, formule, tableau, entite, arrete,
       exercice_n,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE exercice_n_1 END AS exercice_n_1,
       valeur_saisie, montant_saisi, a_saisir,
       colonne_1,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE colonne_2 END AS colonne_2,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE colonne_3 END AS colonne_3,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE colonne_4 END AS colonne_4,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE colonne_5 END AS colonne_5,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE colonne_6 END AS colonne_6,
       CASE WHEN formule_calcul LIKE N'%; colonne 1 seule%' THEN NULL ELSE colonne_7 END AS colonne_7,
       formule_calcul
FROM dbo.fn_ligne_annexe_montant();

GO

