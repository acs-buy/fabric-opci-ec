
-- --- 3 : declarer l'export, apres ecriture du fichier ------------------
CREATE   PROCEDURE dbo.pr_declarer_export_fec
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @profil       VARCHAR (10),
    @nom_fichier  NVARCHAR (400),
    @empreinte    CHAR (64),
    @lignes       INT,
    @total_debit  DECIMAL (19,2),
    @total_credit DECIMAL (19,2),
    @par          NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @familles TABLE (famille VARCHAR (10) PRIMARY KEY);
    IF @profil = 'FISCAL'
        INSERT INTO @familles VALUES ('IMPORTEE');
    ELSE
        INSERT INTO @familles VALUES ('IMPORTEE'), ('DECIDEE'), ('DERIVABLE');

    IF @total_debit <> @total_credit
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Export refuse : le fichier n''est pas equilibre. Un fichier des '
          + N'ecritures comptables porte autant de debit que de credit.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_declarer_export_fec', @entite, @arrete, NULL, @m1, @par);
        THROW 50042, @m1, 1;
    END;
    IF @lignes < 1
    BEGIN
        DECLARE @m2 NVARCHAR (2000) =
            N'Export refuse : aucune ligne a exporter sur l''arrete '
          + @arrete + N' pour le profil ' + @profil + N'.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_declarer_export_fec', @entite, @arrete, NULL, @m2, @par);
        THROW 50042, @m2, 1;
    END;
    -- Un compte sans traduction dans le plan de l'entite rendrait un
    -- champ CompteNum vide, que le reimport rejetterait.
    IF EXISTS (SELECT 1 FROM dbo.v_fec_a_exporter x
               JOIN @familles f ON f.famille = x.famille
               WHERE x.entite = @entite AND x.arrete = @arrete
                 AND x.compte_fichier IS NULL)
    BEGIN
        DECLARE @m3 NVARCHAR (2000) =
            N'Export refuse : des ecritures portent un compte sans traduction '
          + N'dans le plan de comptes de l''entite. Le champ CompteNum serait '
          + N'vide et le reimport le rejetterait. Completer '
          + N'ref_compte_entite pour ces comptes.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_declarer_export_fec', @entite, @arrete, NULL, @m3, @par);
        THROW 50042, @m3, 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO dbo.export_fec
            (profil, perimetre, arrete, entite, nom_fichier,
             empreinte_sha256, lignes, total_debit, total_credit, produit_par)
        VALUES (@profil, 'COMPLET', @arrete, @entite, @nom_fichier,
                @empreinte, @lignes, @total_debit, @total_credit, @par);
        DECLARE @ex INT = CAST(SCOPE_IDENTITY() AS INT);
        INSERT INTO dbo.export_fec_lot (export_id, lot_id)
        SELECT DISTINCT @ex, x.lot_id
        FROM dbo.v_fec_a_exporter x
        JOIN @familles f ON f.famille = x.famille
        WHERE x.entite = @entite AND x.arrete = @arrete;
        COMMIT TRANSACTION;
        SELECT @ex AS export_id;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @m4 NVARCHAR (2000) =
            N'Export refuse. Motif rendu par la base : '
          + LEFT(ERROR_MESSAGE(), 400);
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_declarer_export_fec', @entite, @arrete, NULL,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW 50042, @m4, 1;
    END CATCH;
END;

GO

