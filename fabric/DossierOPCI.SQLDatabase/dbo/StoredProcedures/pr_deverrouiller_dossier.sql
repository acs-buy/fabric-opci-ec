
-- 10. DEVERROUILLER LE DOSSIER : un motif, un demandeur et un decideur
-- distincts, le role qui vise la revue. La trace est un visa REVUE RENVOYE, motif « Déverrouillage : ».
CREATE   PROCEDURE dbo.pr_deverrouiller_dossier
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @motif        NVARCHAR (500) = NULL,
    @demande_par  NVARCHAR (400) = NULL,
    @par          NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51214, N'Déverrouillage refusé : aucun dossier de travail verrouillé pour le véhicule et l''arrêté des sélecteurs.', 1;
    -- 327 fin
    IF NOT EXISTS (SELECT 1 FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete AND verrouille = 1)
        THROW 50351, N'Le dossier de cet arrêté n''est pas verrouillé.', 1;
    SET @motif = NULLIF(LTRIM(RTRIM(@motif)), N'');
    SET @demande_par = NULLIF(LTRIM(RTRIM(@demande_par)), N'');
    IF @motif IS NULL
        THROW 50516, N'Déverrouillage refusé : il exige un motif.', 1;
    IF @demande_par IS NULL
        THROW 50528, N'Déverrouillage refusé : il exige le nom de celui qui le demande.', 1;
    IF @demande_par = @par
        THROW 50517, N'Déverrouillage refusé : celui qui le demande ne peut pas le décider.', 1;
    IF dbo.fn_peut_viser_nature(@entite, @par, 'REVUE', CAST(SYSUTCDATETIME() AS DATE)) = 0
        THROW 50518, N'Déverrouillage refusé : cette personne n''a pas, sur cette entité, le rôle qui vise la revue.', 1;
    DECLARE @le DATETIME2 (3) = SYSUTCDATETIME();
    BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par, decide_le)
    VALUES ('REVUE', @entite + '|' + @arrete, @entite, @arrete, NULL, 'RENVOYE', LEFT(N'Déverrouillage : ' + @motif, 600), @demande_par, @par, @le);
    UPDATE dbo.dossier_verrou SET verrouille = 0, deverrouille_par = @par, deverrouille_le = @le
     WHERE entite = @entite AND arrete = @arrete;
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
    SELECT N'Dossier de l''arrêté ' + @arrete + N' déverrouillé à la demande de ' + @demande_par
         + N'. La revue est renvoyée : elle se reconclut avant un nouveau visa.' AS message;
END;

GO

