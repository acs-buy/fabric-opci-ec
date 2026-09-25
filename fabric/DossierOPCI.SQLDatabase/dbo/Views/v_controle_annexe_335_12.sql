
-- C67 : dans le tableau d'affectation, le total des sommes AFFECTEES
-- doit egaler le total des sommes DISTRIBUABLES. Une somme distribuable
-- non affectee serait sans emploi. La vue le mesure sur la saisie : tant
-- que l'affectation n'est pas saisie, l'ecart vaut le total distribuable.
CREATE   VIEW dbo.v_controle_annexe_335_12 AS
SELECT m.entite, m.arrete,
       SUM(CASE WHEN m.code IN ('I_D_1', 'I_D_2') THEN m.exercice_n
                WHEN m.code = 'I_D_3' THEN -m.exercice_n ELSE 0 END)
                                                   AS distribuable_resultat,
       SUM(CASE WHEN m.code IN ('I_A_1', 'I_A_2', 'I_A_3')
                THEN COALESCE(m.montant_saisi, 0) ELSE 0 END)
                                                   AS affecte_resultat,
       SUM(CASE WHEN m.code IN ('II_D_1', 'II_D_2') THEN m.exercice_n
                WHEN m.code = 'II_D_3' THEN -m.exercice_n ELSE 0 END)
                                                   AS distribuable_pmv,
       SUM(CASE WHEN m.code IN ('II_A_1', 'II_A_2', 'II_A_3')
                THEN COALESCE(m.montant_saisi, 0) ELSE 0 END)
                                                   AS affecte_pmv
FROM dbo.v_ligne_annexe_montant m
WHERE m.article = '335-12'
GROUP BY m.entite, m.arrete;

GO

