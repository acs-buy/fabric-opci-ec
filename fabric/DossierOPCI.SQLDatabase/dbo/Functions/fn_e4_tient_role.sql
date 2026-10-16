
-- @par tient-il, a la date du jour, le role donne sur l'entite ?
CREATE   FUNCTION dbo.fn_e4_tient_role (@entite VARCHAR (20), @role VARCHAR (20), @par NVARCHAR (400))
RETURNS BIT
AS
BEGIN
    RETURN CASE WHEN EXISTS (SELECT 1 FROM dbo.role_mission r
                             WHERE r.entite = @entite AND r.role = @role AND (r.connexion = @par OR r.personne = @par)
                               AND r.du <= CAST(SYSUTCDATETIME() AS DATE) AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
                THEN 1 ELSE 0 END;
END;

GO

