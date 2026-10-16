
-- ------------------------------------------------------------------------------------------------- production
-- Les gardes de la production, dans l'ordre de l'ancienne fn_obstacle_production, jusqu'a « l'arrete est valide pour le
-- client » compris, messages inchanges (contrat, 3.1, point 3, 1).
CREATE   FUNCTION dbo.fn_garde_production (@entite VARCHAR (20), @arrete VARCHAR (20), @livrable VARCHAR (20), @par NVARCHAR (400))
RETURNS NVARCHAR (2000)
AS
BEGIN
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE);
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_livrable WHERE code = @livrable)
        RETURN N'livrable inconnu : ' + ISNULL(@livrable, N'vide') + N'.';
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
        RETURN N'arrêté inconnu pour cette entité.';
    IF NOT EXISTS (SELECT 1 FROM dbo.role_mission r
                   WHERE r.entite = @entite AND (r.connexion = @par OR r.personne = @par)
                     AND r.du <= @le AND (r.au IS NULL OR r.au > @le))
        RETURN N'cette personne ne tient aucun rôle de mission sur l''entité ' + @entite + N'.';
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_livrable WHERE code = @livrable AND produit_etape_6 = 1)
        RETURN N'le livrable ' + @livrable + N' n''est pas produit par la solution ; seuls les comptes annuels, le rapport de l''expert-comptable et le DIP le sont.';
    IF NOT EXISTS (SELECT 1 FROM dbo.v_livrables_dus WHERE entite = @entite AND arrete = @arrete AND livrable = @livrable)
        RETURN N'le livrable ' + @livrable + N' n''est pas dû à l''arrêté ' + @arrete + N'.';
    IF dbo.fn_revue_visee(@entite, @arrete) = 0
        RETURN N'la revue de l''arrêté n''est pas visée.';
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 1
        RETURN N'l''arrêté est validé pour le client ; une nouvelle production suppose sa réouverture.';
    RETURN NULL;
END;

GO

