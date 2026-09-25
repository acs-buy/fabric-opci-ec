-- C35 : un passage du coffre inacheve depuis plus de 2 heures. Il a
-- echoue sans le dire, et l'ecran affiche un releve qui ne finira pas.
CREATE   VIEW dbo.v_controle_releve_inacheve AS
SELECT id, passage, chemin_racine, debute_le, releve_par,
       DATEDIFF(MINUTE, debute_le, SYSUTCDATETIME()) AS minutes_ecoulees
FROM dbo.releve_coffre
WHERE acheve_le IS NULL
  AND DATEDIFF(MINUTE, debute_le, SYSUTCDATETIME()) > 120;

GO

