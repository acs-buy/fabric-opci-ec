CREATE   VIEW dbo.v_bilan_passif AS
SELECT entite, arrete, ordre, code, libelle, type_ligne,
       exercice_n, exercice_n_1, supprimable, article, renvoi
FROM dbo.v_ligne_etat_montant WHERE etat = 'BILAN_PASSIF';

GO

