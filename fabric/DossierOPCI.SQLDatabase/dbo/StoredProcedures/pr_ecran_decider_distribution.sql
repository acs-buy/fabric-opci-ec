CREATE   PROCEDURE dbo.pr_ecran_decider_distribution
    @entite VARCHAR (20),
    @exercice VARCHAR (20),
    @categorie VARCHAR (30),
    @montant DECIMAL (19,2),
    @assemblee DATE,
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    -- 15/10/2026 : une personne vide ou NULL se refuse en francais, avant tout le reste
    IF NULLIF(LTRIM(RTRIM(@par)), N'') IS NULL
        THROW 50825, N'Décision refusée : votre compte ne tient pas, sur ce dossier, le rôle habilité à enregistrer la décision de distribution.', 1;
    -- 51323 (15/11/2026) : action 29, associe du vehicule. Juge sur @par, celui qui clique, par sa connexion, avant toute ecriture (la session SQL d'une
    -- Data function est celle du proprietaire). Un semis ecrit sans cette garde.
    IF ISNULL(TRY_CAST(SESSION_CONTEXT(N'semis') AS INT), 0) <> 1
       AND EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite) AND NOT EXISTS (SELECT 1 FROM dbo.role_mission r WHERE r.connexion = NULLIF(LTRIM(RTRIM(@par)), N'') AND r.role = 'ASSOCIE' AND r.entite = @entite AND r.du <= CAST(SYSUTCDATETIME() AS DATE) AND (r.au IS NULL OR r.au > CAST(SYSUTCDATETIME() AS DATE)))
        THROW 51323, N'Décision refusée : la distribution se décide par l''associé du véhicule, rôle que votre adresse de connexion ne tient pas.', 1;
    BEGIN TRY
        EXEC dbo.pr_decider_distribution @entite, @exercice, @categorie, @montant, @assemblee, @par;
        UPDATE dbo.decision_distribution
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE entite = @entite AND exercice = @exercice AND categorie = @categorie;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.decision_distribution
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE entite = @entite AND exercice = @exercice AND categorie = @categorie;
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

