

-- 8. CONCLURE LA REVUE : un vehicule ; admis depuis A_CONCLURE, CONCLUE et RENVOYEE.
CREATE   PROCEDURE dbo.pr_conclure_revue
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @conclusion  NVARCHAR (4000),
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @m NVARCHAR (400);
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND forme_vehicule IS NOT NULL)
    BEGIN
        SET @m = N'Conclusion refusée : l''entité ' + ISNULL(@entite, N'vide') + N' n''est pas un véhicule ; la revue porte sur le véhicule et couvre ses filiales.';
        THROW 50520, @m, 1;
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50322, N'La revue se conclut sur un arrêté ouvert.', 1;
    IF NULLIF(LTRIM(RTRIM(@conclusion)), N'') IS NULL
        THROW 50323, N'La conclusion générale est un texte.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de conclure à nouveau.', 1;
    IF dbo.fn_etat_revue(@entite, @arrete) = 'VISEE'
        THROW 50510, N'Conclusion refusée : la revue est visée ; déverrouiller le dossier avant de la reconclure.', 1;
    IF EXISTS (SELECT 1 FROM dbo.conclusion_revue WHERE entite = @entite AND arrete = @arrete)
        UPDATE dbo.conclusion_revue SET conclusion = @conclusion, conclu_par = @par, conclu_le = SYSUTCDATETIME()
         WHERE entite = @entite AND arrete = @arrete;
    ELSE
        INSERT INTO dbo.conclusion_revue (entite, arrete, conclusion, conclu_par) VALUES (@entite, @arrete, @conclusion, @par);
    DECLARE @cycles INT = (SELECT COUNT(*) FROM dbo.ref_cycle c WHERE dbo.fn_cycle_au_programme(@entite, @arrete, c.code) = 1);
    DECLARE @conclus INT = (SELECT COUNT(*) FROM dbo.conclusion_cycle c WHERE c.entite = @entite AND c.arrete = @arrete
                            AND dbo.fn_cycle_au_programme(@entite, @arrete, c.cycle) = 1);
    SELECT @conclus AS cycles_conclus, @cycles AS cycles_du_programme,
           N'Revue conclue : ' + CAST(@conclus AS NVARCHAR (10)) + N' cycle(s) conclu(s) sur ' + CAST(@cycles AS NVARCHAR (10)) + N' au programme.' AS message;
END;

GO

