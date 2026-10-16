
-- pr_ecran_demander_reouverture : 1 refus
-- ------------------------------------------------------------------------------------------------- 2.4 : les 3 procedures d'ecran
CREATE   PROCEDURE dbo.pr_ecran_demander_reouverture @entite VARCHAR (20), @arrete VARCHAR (20), @motif NVARCHAR (800), @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE), @p VARCHAR (20), @m NVARCHAR (400);
    IF dbo.fn_membre_equipe(@entite, @arrete, @par, @le) = 0
        THROW 50981, N'Demande refusée : votre adresse de connexion n''est rattachée à aucun membre de l''équipe de ce dossier.', 1;
    IF dbo.fn_decide_reouverture(@entite, @par, @le) = 1
        THROW 50982, N'Demande refusée : vous décidez les réouvertures de ce dossier ; la demande vient d''un autre membre de l''équipe.', 1;
    IF dbo.fn_valide_pour_client(@entite, @arrete) = 0
        THROW 50983, N'Demande refusée : l''arrêté n''est pas validé pour le client ; il n''y a rien à rouvrir.', 1;
    SET @p = dbo.fn_arrete_clos_posterieur(@entite, @arrete);
    IF @p IS NOT NULL
    BEGIN
        SET @m = N'Demande refusée : l''arrêté postérieur du ' + dbo.fn_date_ecran(@p) + N' est clos ; la réouverture commence par le dernier arrêté clos.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50984, @m, 1; END
    END;
    IF EXISTS (SELECT 1 FROM dbo.demande_reouverture WHERE entite = @entite AND arrete = @arrete AND nature = 'REOUVERTURE' AND etat = 'EN_ATTENTE')
        THROW 50985, N'Demande refusée : une demande attend déjà la décision du chef de mission pour cet arrêté.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    IF @motif IS NULL
        THROW 50986, N'Demande refusée : elle exige un motif, qui dit quel lot tardif justifie de rouvrir l''arrêté.', 1;
    INSERT INTO dbo.demande_reouverture (entite, arrete, nature, motif, demande_par) VALUES (@entite, @arrete, 'REOUVERTURE', @motif, @par);
    SELECT SCOPE_IDENTITY() AS demande_id,
           N'Réouverture de l''arrêté du ' + dbo.fn_date_ecran(@arrete) + N' demandée ; elle attend la décision du chef de mission.' AS message;
END;

GO

