CREATE   PROCEDURE dbo.pr_ecran_reprendre_acceptation
    @entite VARCHAR (20),
    @motif NVARCHAR (800),
    @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 51322 (15/11/2026) : action 7, viseur de l'acceptation ; dans le TRY : le CATCH ecrit le refus sur la ligne d'acceptation. Juge sur @par, celui qui clique, par sa connexion, avant toute ecriture (la session SQL d'une
        -- Data function est celle du proprietaire). Un semis ecrit sans cette garde.
        IF ISNULL(TRY_CAST(SESSION_CONTEXT(N'semis') AS INT), 0) <> 1
           AND EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite) AND dbo.fn_peut_viser_nature(@entite, NULLIF(LTRIM(RTRIM(@par)), N''), 'ACCEPTATION', CAST(SYSUTCDATETIME() AS DATE)) = 0
            THROW 51322, N'Reprise refusée : une acceptation refusée se reprend par celui qui décide de l''acceptation, rôle que votre adresse de connexion ne tient pas.', 1;
        EXEC dbo.pr_reprendre_acceptation @entite, @motif, @par;
        UPDATE dbo.acceptation_mission
           SET message_ecran = NULL, message_ecran_le = NULL,
               message_ecran_pour = NULL
         WHERE id = (SELECT TOP 1 id FROM dbo.acceptation_mission
                    WHERE entite = @entite ORDER BY cree_le DESC);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.acceptation_mission
           SET message_ecran      = LEFT(ERROR_MESSAGE(), 2000),
               message_ecran_le   = SYSUTCDATETIME(),
               message_ecran_pour = LEFT(@par, 200)
         WHERE id = (SELECT TOP 1 id FROM dbo.acceptation_mission
                    WHERE entite = @entite ORDER BY cree_le DESC);
    
        -- 13/09/2026 : la relance rend le refus VISIBLE. Sans elle le
        -- service repond 200 et le portail affiche un succes.
        THROW;
    END CATCH;
END;

GO

