
-- 0.5 : decide une reouverture la connexion qui tient, sur l'entite, un role habilite au visa de cloture.
CREATE   FUNCTION dbo.fn_decide_reouverture (@entite VARCHAR (20), @connexion NVARCHAR (400), @le DATE)
RETURNS BIT
AS
BEGIN
    IF NULLIF(LTRIM(RTRIM(@connexion)), N'') IS NULL RETURN 0;
    RETURN CASE WHEN EXISTS (
        SELECT 1 FROM dbo.role_mission r JOIN dbo.role_nature_visa n ON n.role_code = r.role AND n.nature = 'CLOTURE'
        WHERE r.entite = @entite AND r.connexion = @connexion AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        THEN 1 ELSE 0 END;
END;

GO

