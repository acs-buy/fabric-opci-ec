CREATE   PROCEDURE dbo.pr_ecran_annuler_lot
    @lot_id INT,
    @par NVARCHAR (200),
    @motif NVARCHAR (600)
AS
BEGIN
    SET NOCOUNT ON;
    -- 24/10/2026 : un champ vide se refuse en francais avant toute ecriture, par un texte propre au champ.
    -- Place : avant le TRY de l'enveloppe.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF @lot_id IS NULL
        THROW 51228, N'Choisissez dans la grille « Lots de valorisation de l’arrêté » un lot au statut proposé.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @motif COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51229, N'Annulation refusée : le motif de l''annulation est obligatoire.', 1;
    -- 51321 (15/11/2026) : action 28, equipe du dossier du lot. Juge sur @par, celui qui clique, par sa connexion, avant toute ecriture (la session SQL d'une
    -- Data function est celle du proprietaire). Un semis ecrit sans cette garde.
    IF ISNULL(TRY_CAST(SESSION_CONTEXT(N'semis') AS INT), 0) <> 1
       AND EXISTS (SELECT 1 FROM dbo.lot_ecritures l WHERE l.id = @lot_id AND dbo.fn_membre_equipe(l.entite, l.arrete, NULLIF(LTRIM(RTRIM(@par)), N''), CAST(SYSUTCDATETIME() AS DATE)) = 0)
        THROW 51321, N'Action refusée : seule l''équipe du dossier peut annuler un lot de ce dossier.', 1;
    BEGIN TRY
        EXEC dbo.pr_annuler_lot @lot_id, @par, @motif;
        UPDATE dbo.lot_ecritures
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = @lot_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.lot_ecritures
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE id = @lot_id;
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

