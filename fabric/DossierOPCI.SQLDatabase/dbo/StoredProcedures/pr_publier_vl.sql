
-- pr_publier_vl : 1 refus
-- ------------------------------------------------------------------ n° 8 : les accents de 50034

-- --- 8 : la publication et l'obligation, alignees sur le role --------
-- Les 2 procedures existaient. Elles verifiaient l'etat des lots, jamais
-- la qualite de celui qui decide : elles ecrivent desormais dans dbo.visa,
-- ce qui les soumet au verrou K8 comme les 4 autres.
CREATE   PROCEDURE dbo.pr_publier_vl
    @entite VARCHAR (20),
    @arrete VARCHAR (20),
    @par    NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        DECLARE @lot_propose INT =
            (SELECT TOP 1 l.id FROM dbo.lot_ecritures l
             WHERE l.entite = @entite AND l.arrete = @arrete
               AND l.statut = 'PROPOSE');
        IF @lot_propose IS NOT NULL
        BEGIN
            DECLARE @m1 NVARCHAR (2000) =
                N'Publication refusée : le lot ' + CAST(@lot_propose AS NVARCHAR (20))
                + N' est proposé et non visé. La valeur liquidative ne se publie '
                + N'pas tant qu''un lot attend le visa du chef de mission.';
            BEGIN SET @m1 = REPLACE(@m1, N'%', N'%%'); THROW 50034, @m1, 1; END
        END;

        DECLARE @propose NVARCHAR (200) =
            dbo.fn_proposant('PUBLICATION', @entite + '|' + @arrete);
        IF @propose IS NULL
            THROW 50034, N'Publication refusée : aucun lot n''a été proposé pour cette entité à cet arrêté, il n''y a donc rien à publier.', 1;

        DECLARE @ref VARCHAR (60) = @entite + '|' + @arrete;
        EXEC dbo.pr_garde_visa 'PUBLICATION', @ref, 'VISE', @par, NULL;

        BEGIN TRANSACTION;
        -- Le visa d'abord : son declencheur refuse le publiant qui serait
        -- l'auteur des ecritures, ou qui ne tiendrait pas de role habilite.
        INSERT INTO dbo.visa (nature, objet_ref, entite, arrete, cycle,
                              decision, propose_par, decide_par)
        VALUES ('PUBLICATION', @entite + '|' + @arrete, @entite, @arrete, NULL,
                'VISE', @propose, @par);

        INSERT INTO dbo.publication_vl
            (entite, arrete, valeur_liquidative, nombre_parts,
             version_regles, publie_par)
        SELECT v.entite, v.arrete, v.valeur_liquidative, v.nombre_parts,
               v.version_regles, @par
        FROM dbo.v_valeur_liquidative v
        WHERE v.entite = @entite AND v.arrete = @arrete
          AND v.valeur_liquidative IS NOT NULL;
        IF @@ROWCOUNT = 0
            THROW 50034,
                N'Publication refusée : aucune valeur liquidative n''est rendue pour cette entité à cet arrêté. Vérifier le nombre de parts et les lots validés, ou lire le motif de refus de la vue de la valeur liquidative.',
                1;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_publier_vl', @entite, @arrete,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END

GO

