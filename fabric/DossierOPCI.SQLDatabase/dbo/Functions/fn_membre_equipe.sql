
-- 0.5 : membre de l'equipe de la mission du dossier, par la connexion seule, a la date @le ; pour une filiale, aussi les
-- membres du vehicule qui la detient a l'arrete en cause (v_perimetre_vehicule ; sans arrete, a l'un de ses arretes).
CREATE   FUNCTION dbo.fn_membre_equipe (@entite VARCHAR (20), @arrete VARCHAR (20), @connexion NVARCHAR (400), @le DATE)
RETURNS BIT
AS
BEGIN
    IF NULLIF(LTRIM(RTRIM(@connexion)), N'') IS NULL RETURN 0;
    RETURN CASE WHEN EXISTS (
        SELECT 1 FROM dbo.role_mission r
        WHERE r.connexion = @connexion AND r.role IN ('ASSOCIE', 'CHEF_MISSION', 'PREPARATEUR', 'REVISEUR')
          AND r.du <= @le AND (r.au IS NULL OR r.au > @le)
          AND (r.entite = @entite
               OR r.entite IN (SELECT p.vehicule FROM dbo.v_perimetre_vehicule p
                               WHERE p.entite = @entite AND p.vehicule <> @entite AND (@arrete IS NULL OR p.arrete = @arrete))))
        THEN 1 ELSE 0 END;
END;

GO

