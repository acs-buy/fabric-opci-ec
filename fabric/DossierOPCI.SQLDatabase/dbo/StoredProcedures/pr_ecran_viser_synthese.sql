
CREATE   PROCEDURE dbo.pr_ecran_viser_synthese
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @decision VARCHAR (10),
    @motif NVARCHAR (800) = NULL,
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- Place : avant le TRY de l'enveloppe.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51224, N'Visa refusé : aucune synthèse proposée n''attend de visa pour le véhicule du sélecteur Véhicule à cet arrêté ; une synthèse visée ne se vise plus.', 1;
    IF @decision = 'RENVOYE' AND ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @motif COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51225, N'Renvoi refusé : un renvoi porte son motif. Sans lui, le préparateur ne sait pas ce qu''il doit corriger.', 1;
    -- 327 fin
    BEGIN TRY
        EXEC dbo.pr_viser_synthese @entite, @arrete, @decision, @motif, @par;
        UPDATE dbo.synthese_proposee
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = (SELECT TOP 1 id FROM dbo.synthese_proposee
                    WHERE entite = @entite AND arrete = @arrete
                      AND perime_le IS NULL ORDER BY propose_le DESC);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.synthese_proposee
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE id = (SELECT TOP 1 id FROM dbo.synthese_proposee
                    WHERE entite = @entite AND arrete = @arrete
                      AND perime_le IS NULL ORDER BY propose_le DESC);
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

