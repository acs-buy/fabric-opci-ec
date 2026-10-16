
-- 0.8 : une personne s'affiche par le nom que porte role_mission.personne pour sa connexion sur l'entite, le role de
-- plus petit ref_role.ordre l'emportant ; une connexion sans ligne s'affiche telle quelle.
CREATE   FUNCTION dbo.fn_nom_personne_ecran (@entite VARCHAR (20), @qui NVARCHAR (400))
RETURNS NVARCHAR (400)
AS
BEGIN
    RETURN ISNULL((SELECT TOP (1) r.personne FROM dbo.role_mission r LEFT JOIN dbo.ref_role o ON o.code = r.role
                   WHERE r.entite = @entite AND r.connexion = @qui AND NULLIF(r.personne, N'') IS NOT NULL
                   ORDER BY ISNULL(o.ordre, 999), r.id DESC), @qui);
END;

GO

