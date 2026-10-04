

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

