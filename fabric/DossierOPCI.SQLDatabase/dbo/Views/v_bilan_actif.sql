

-- --- 3 : les 3 etats, au format du modele ---------------------------
CREATE   VIEW dbo.v_bilan_actif AS
SELECT entite, arrete, ordre, code, libelle, type_ligne,
       exercice_n, exercice_n_1, supprimable, article, renvoi
FROM dbo.v_ligne_etat_montant WHERE etat = 'BILAN_ACTIF';

GO

