
-- Les controles communs a toute action de l'ecran sur un vehicule et un arrete : le vehicule, l'arrete, le droit, le verrou.
CREATE   FUNCTION dbo.fn_e3_refus_commun (@vehicule VARCHAR (20), @arrete VARCHAR (20), @par NVARCHAR (400))
RETURNS NVARCHAR (1000)
AS
BEGIN
    IF NULLIF(LTRIM(RTRIM(@vehicule)), '') IS NULL
       OR NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @vehicule AND forme_vehicule IS NOT NULL)
        RETURN N'50701|Choisissez le véhicule dans le sélecteur Véhicule.';
    IF NULLIF(LTRIM(RTRIM(@arrete)), '') IS NULL
       OR NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @vehicule AND arrete = @arrete)
        RETURN N'50702|Choisissez l''arrêté dans le sélecteur Arrêté : celui reçu n''existe pas pour ce véhicule.';
    IF dbo.fn_membre_equipe(@vehicule, @arrete, @par, CAST(SYSUTCDATETIME() AS DATE)) = 0
        RETURN N'50700|Action refusée : votre adresse de connexion n''est rattachée à aucun membre de l''équipe de ce dossier.';
    IF dbo.fn_dossier_verrouille(@vehicule, @arrete) = 1
        RETURN N'50303|Le dossier de cet arrêté est visé et verrouillé.';
    RETURN NULL;
END;

GO

