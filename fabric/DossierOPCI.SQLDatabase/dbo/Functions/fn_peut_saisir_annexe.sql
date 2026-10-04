
CREATE   FUNCTION dbo.fn_peut_saisir_annexe (
    @entite VARCHAR (20),
    @qui    NVARCHAR (400),
    @le     DATE
)
RETURNS BIT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM dbo.role_mission r
               WHERE r.entite = @entite AND (r.connexion = @qui OR r.personne = @qui)
                 AND r.role IN ('ASSOCIE', 'CHEF_MISSION', 'PREPARATEUR', 'REVISEUR')
                 AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        RETURN 1;
    RETURN 0;
END;

GO

