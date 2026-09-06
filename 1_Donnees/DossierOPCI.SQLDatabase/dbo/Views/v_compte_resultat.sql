CREATE   VIEW dbo.v_compte_resultat AS
SELECT entite, arrete, ordre, code, libelle, type_ligne, romain,
       exercice_n, exercice_n_1, supprimable, article, renvoi
FROM dbo.v_ligne_etat_montant WHERE etat = 'RESULTAT';

GO

