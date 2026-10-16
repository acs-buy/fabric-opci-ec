
-- pr_viser_obligation_distribution : 2 refus
-- ------------------------------------------------------------------ n° 5 et n° 8 : viser ou renvoyer la base d'une categorie
-- UPDATE de la ligne proposee, VISEE ou RENVOYEE avec motif. 5 refus 50036, tous avant l'ecriture, dans cet ordre :
-- aucun arrete annuel ; VL de la cloture non publiee (en vigueur) ; base non proposee ; categorie deja visee ; proposant
-- introuvable (la ligne n'en porte pas).
CREATE   PROCEDURE dbo.pr_viser_obligation_distribution
    @entite    VARCHAR (20),
    @exercice  VARCHAR (20),
    @categorie VARCHAR (20),
    @decision  VARCHAR (10)   = 'VISE',
    @motif     NVARCHAR (600) = NULL,
    @vise_par  NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @arrete_annuel VARCHAR (20), @id INT, @etat VARCHAR (12), @propose NVARCHAR (400), @tc INT = @@TRANCOUNT;
    SELECT @arrete_annuel = arrete FROM dbo.arrete_mission
    WHERE entite = @entite AND exercice = @exercice AND type_arrete = 'ANNUEL';
    SELECT @id = id, @etat = etat, @propose = propose_par FROM dbo.obligation_distribution
    WHERE entite = @entite AND exercice = COALESCE(@arrete_annuel, @exercice) AND categorie = @categorie;
    BEGIN TRY
        IF @arrete_annuel IS NULL
        BEGIN
            DECLARE @m1 NVARCHAR (2000) =
                N'Visa refusé : les sommes distribuables sont celles de '
              + N'l''exercice, I de l''article L. 214-69 du code monétaire et '
              + N'financier. L''exercice ' + dbo.fn_date_ecran(@exercice) + N' ne porte aucune '
              + N'clôture annuelle ouverte : un arrêté de valeur liquidative '
              + N'en cours d''année ne calcule pas l''obligation.';
            BEGIN SET @m1 = REPLACE(@m1, N'%', N'%%'); THROW 50036, @m1, 1; END
        END;
        IF NOT EXISTS (SELECT 1 FROM dbo.publication_vl
                       WHERE entite = @entite AND arrete = @arrete_annuel AND perimee_le IS NULL)
        BEGIN
            DECLARE @m2 NVARCHAR (2000) =
                N'Visa refusé : la valeur liquidative de la clôture annuelle '
              + dbo.fn_date_ecran(@arrete_annuel) + N' n''est pas publiée. L''obligation se '
              + N'calcule sur des comptes arrêtés.';
            BEGIN SET @m2 = REPLACE(@m2, N'%', N'%%'); THROW 50036, @m2, 1; END
        END;
        IF @id IS NULL OR ISNULL(@etat, '') NOT IN ('PROPOSEE', 'VISEE')
            THROW 50036, N'Visa refusé : la base de cette catégorie n''est pas proposée. Le préparateur la propose d''abord.', 1;
        IF @etat = 'VISEE'
            THROW 50036, N'Visa refusé : cette catégorie est déjà visée pour l''exercice.', 1;
        IF NULLIF(LTRIM(RTRIM(@propose)), N'') IS NULL
            THROW 50036, N'Visa refusé : la ligne de la catégorie ne porte aucun proposant inscrit ; la base se propose de nouveau.', 1;

        DECLARE @ref VARCHAR (30) = CAST(@id AS VARCHAR (30));
        BEGIN TRANSACTION;
        EXEC dbo.pr_garde_visa 'OBLIGATION', @ref, @decision, @vise_par, @motif;
        UPDATE dbo.obligation_distribution
           SET etat = CASE @decision WHEN 'VISE' THEN 'VISEE' ELSE 'RENVOYEE' END, vise_par = @vise_par, vise_le = SYSUTCDATETIME()
         WHERE id = @id;
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle, decision, motif, propose_par, decide_par)
        VALUES ('OBLIGATION', @ref, @entite, @arrete_annuel, NULL, @decision, @motif, @propose, @vise_par);
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @tc = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        IF @tc = 0
            INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, message, refuse_pour)
            VALUES ('pr_viser_obligation_distribution', @entite, COALESCE(@arrete_annuel, @exercice), LEFT(ERROR_MESSAGE(), 2000), @vise_par);
        THROW;
    END CATCH;
END;

GO

