
CREATE   PROCEDURE dbo.pr_ajouter_filiale
    @client         VARCHAR (20),
    @code           VARCHAR (20),
    @denomination   NVARCHAR (400) = NULL,
    @forme_sociale  VARCHAR (10)   = 'SCI',
    @droits_de_vote DECIMAL (9, 6),
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @client AND est_client = 1)
        THROW 50211, N'Le client n''existe pas, ou l''entité désignée n''est pas un client du cabinet.', 1;
    IF @code IS NULL OR LTRIM(RTRIM(@code)) = ''
        THROW 50210, N'Le code de la filiale est obligatoire.', 1;
    IF @code = @client
        THROW 50212, N'Un client n''est pas sa propre filiale.', 1;
    IF @droits_de_vote IS NULL OR @droits_de_vote <= 0 OR @droits_de_vote > 1
        THROW 50213, N'Les droits de vote se donnent entre 0 et 1, par exemple 0,80 pour 80 %.', 1;
    IF EXISTS (SELECT 1 FROM dbo.eligibilite_participation WHERE entite_mere = @client AND entite_fille = @code)
        THROW 50214, N'Cette filiale est déjà au périmètre de ce client.', 1;

    BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @code)
    BEGIN
        IF @denomination IS NULL
            THROW 50215, N'La filiale est nouvelle : sa dénomination est obligatoire.', 1;
        INSERT INTO dbo.ref_entite
            (code, denomination, forme_sociale, adresse_1, adresse_2, code_postal, ville, pays,
             dirigeant_nom, dirigeant_qualite, cloture, modifie_par, modifie_le, plan_propre_en_service, est_client, cree_le)
        SELECT @code, @denomination, @forme_sociale, m.adresse_1, m.adresse_2, m.code_postal, m.ville, m.pays,
               m.dirigeant_nom, m.dirigeant_qualite, m.cloture, @par, SYSUTCDATETIME(), 0, 0, SYSUTCDATETIME()
        FROM dbo.ref_entite m WHERE m.code = @client;
    END;
    INSERT INTO dbo.eligibilite_participation (entite_mere, entite_fille, droits_de_vote, qualifie_par, qualifie_le)
    VALUES (@client, @code, @droits_de_vote, @par, SYSUTCDATETIME());
    INSERT INTO dbo.journal_perimetre (entite_mere, entite_fille, action, detail, fait_par)
    VALUES (@client, @code, 'AJOUT', N'droits de vote ' + FORMAT(@droits_de_vote, 'P2', 'fr-FR'), @par);
    COMMIT;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @code AS filiale,
           N'Filiale ' + @code + N' ajoutée au périmètre de ' + @client + N'. Sa balance sera réclamée à la révision.' AS message;
END;

GO

