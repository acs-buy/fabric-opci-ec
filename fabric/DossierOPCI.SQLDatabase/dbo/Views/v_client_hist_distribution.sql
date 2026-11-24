-- La distribution par part pour le client : dates de valeur egales a un arrete vise de l'entite.
CREATE   VIEW dbo.v_client_hist_distribution AS
SELECT d.entite, d.date_valeur, d.distribution_totale, d.distribution_par_part
FROM dbo.v_distribution_par_part d
WHERE EXISTS (SELECT 1 FROM dbo.v_arrete_client c WHERE c.entite = d.entite AND c.arrete = d.date_valeur);

GO

