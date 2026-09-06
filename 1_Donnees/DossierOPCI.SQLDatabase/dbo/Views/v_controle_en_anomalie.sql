
CREATE   VIEW dbo.v_controle_en_anomalie AS
SELECT vue, code, libelle, genre, fondement, lignes, anomalies, lecture
FROM dbo.v_dernier_releve_controle
WHERE anomalies > 0 OR message IS NOT NULL;

GO

