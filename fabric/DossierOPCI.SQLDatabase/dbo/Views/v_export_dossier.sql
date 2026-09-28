CREATE   VIEW dbo.v_export_dossier AS
-- Le dernier depot reussi de CHAQUE FICHIER d'un dossier, par entite et par arrete.
-- Tous les classeurs passent par dbo.pr_deposer_classeur depuis le 28/09/2026 : partitionner par
-- dossier seulement ferait qu'un export d'OD remplace le dossier de travail sur la page. Chaque
-- fichier garde donc sa ligne, et son lien.
SELECT e.entite, e.arrete, e.fichier, e.web_url, e.chemin_onelake, e.taille,
       e.depose_par, e.depose_le
FROM (SELECT x.*, ROW_NUMBER() OVER (PARTITION BY x.entite, x.arrete, x.fichier ORDER BY x.id DESC) AS rang
      FROM dbo.export_dossier x WHERE x.statut = 'FAIT') AS e
WHERE e.rang = 1;

GO

