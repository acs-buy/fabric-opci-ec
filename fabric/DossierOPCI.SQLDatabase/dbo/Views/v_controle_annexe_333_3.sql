
CREATE   VIEW dbo.v_controle_annexe_333_3 AS
SELECT a.entite, a.arrete,
       a.colonne_1 AS actif_net_fin,
       m.exercice_n AS capitaux_propres,
       CAST(a.colonne_1 - m.exercice_n AS DECIMAL (19, 2)) AS ecart,
       a.colonne_2 AS actif_net_fin_n1,
       m.exercice_n_1 AS capitaux_propres_n1,
       CAST(a.colonne_2 - m.exercice_n_1 AS DECIMAL (19, 2)) AS ecart_n1
FROM dbo.v_ligne_annexe_montant a
JOIN dbo.v_ligne_etat_montant m ON m.entite = a.entite AND m.arrete = a.arrete AND m.code = 'P_CP'
WHERE a.article = '333-3' AND a.code = 'AN_FIN';

GO

