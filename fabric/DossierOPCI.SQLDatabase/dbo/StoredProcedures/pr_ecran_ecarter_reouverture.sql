
CREATE   PROCEDURE dbo.pr_ecran_ecarter_reouverture @entite VARCHAR (20), @arrete VARCHAR (20), @motif_ecart NVARCHAR (800), @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @le DATE = CAST(SYSUTCDATETIME() AS DATE), @id INT, @auteur NVARCHAR (400);
    IF dbo.fn_decide_reouverture(@entite, @par, @le) = 0
        THROW 50992, N'Écart refusé : la réouverture d''un arrêté se décide par le chef de mission du dossier.', 1;
    SELECT @id = id, @auteur = demande_par FROM dbo.demande_reouverture
    WHERE entite = @entite AND arrete = @arrete AND nature = 'REOUVERTURE' AND etat = 'EN_ATTENTE';
    IF @id IS NULL
        THROW 50993, N'Écart refusé : aucune demande de réouverture n''attend sur cet arrêté.', 1;
    IF @auteur = @par
        THROW 50994, N'Écart refusé : vous avez demandé cette réouverture ; un autre membre habilité la décide.', 1;
    SET @motif_ecart = NULLIF(LTRIM(RTRIM(@motif_ecart)), N'');
    IF @motif_ecart IS NULL
        THROW 50995, N'Écart refusé : il exige un motif, qui dit pourquoi l''arrêté reste clos.', 1;
    -- n'ecrit que sur une demande encore en attente : une decision concurrente passee entre-temps rend 50993
    UPDATE dbo.demande_reouverture SET etat = 'ECARTEE', motif_ecart = @motif_ecart, decide_par = @par, decide_le = SYSUTCDATETIME()
    WHERE id = @id AND etat = 'EN_ATTENTE';
    IF @@ROWCOUNT = 0
        THROW 50993, N'Écart refusé : aucune demande de réouverture n''attend sur cet arrêté.', 1;
    SELECT @id AS demande_id, N'Demande de réouverture de l''arrêté du ' + dbo.fn_date_ecran(@arrete) + N' écartée ; l''arrêté reste clos.' AS message;
END;

GO

