
CREATE   VIEW dbo.v_export_dossier AS
-- Le dernier export reussi de chaque dossier, par entite et par arrete.
SELECT e.entite, e.arrete, e.fichier, e.web_url, e.chemin_onelake, e.taille,
       e.depose_par, e.depose_le
FROM (SELECT x.*, ROW_NUMBER() OVER (PARTITION BY x.entite, x.arrete ORDER BY x.id DESC) AS rang
      FROM dbo.export_dossier x WHERE x.statut = 'FAIT') AS e
WHERE e.rang = 1;

GO

