
-- Le role courant, a la date du jour.
CREATE   VIEW dbo.v_role_courant AS
SELECT entite, role, personne, du, au, role_libelle, vise
FROM dbo.v_role_a_la_date
WHERE du <= CAST(SYSUTCDATETIME() AS DATE)
  AND (au IS NULL OR au > CAST(SYSUTCDATETIME() AS DATE));

GO

