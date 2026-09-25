
-- --- 3 : generer le brouillon depuis une intention ---------------------
-- Le brouillon existant est la seule porte d'entree d'un lot decide : la
-- procedure ecrit dedans, puis pr_valider_brouillon fait le lot.
CREATE   PROCEDURE dbo.pr_generer_depuis_intention
    @intention_id INT,
    @par          NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20),
            @cote VARCHAR (30), @question INT, @mode VARCHAR (12),
            @compte VARCHAR (20), @contrepartie VARCHAR (20),
            @libelle NVARCHAR (200), @montant DECIMAL (19,2),
            @sens VARCHAR (6), @lot INT;
    SELECT @entite = entite, @arrete = arrete, @cote = feuille_cote,
           @question = question_id, @mode = mode, @compte = compte_num,
           @contrepartie = compte_contrepartie, @libelle = libelle,
           @montant = montant_resolu, @sens = sens_resolu, @lot = lot_id
    FROM dbo.v_intention_resolue WHERE id = @intention_id;

    IF @entite IS NULL
    BEGIN
        DECLARE @m0 NVARCHAR (2000) =
            N'Generation refusee : aucune intention sous cet identifiant.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_generer_depuis_intention', NULL, NULL, NULL, @m0, @par);
        THROW 50041, @m0, 1;
    END;

    -- B17 : une intention deja materialisee ne se regenere pas en silence.
    IF @lot IS NOT NULL
    BEGIN
        DECLARE @m1 NVARCHAR (2000) =
            N'Regeneration refusee : l''intention ' + CAST(@intention_id AS VARCHAR (12))
          + N' a deja produit le lot ' + CAST(@lot AS VARCHAR (12))
          + N'. La cible reste lisible comme intention et l''ecart se lit '
          + N'dans v_ecart_regeneration ; l''annuler passe par un lot '
          + N'd''annulation, jamais par un recalcul silencieux.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_generer_depuis_intention', @entite, @arrete, @cote, @m1, @par);
        THROW 50041, @m1, 1;
    END;

    -- Une cible deja atteinte ne produit aucune ecriture, et le dit.
    IF @montant IS NULL OR @montant = 0
    BEGIN
        DECLARE @m2 NVARCHAR (2000) =
            N'Generation refusee : le solde du compte ' + @compte
          + N' egale deja la cible. Aucune ecriture n''a lieu d''etre.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_generer_depuis_intention', @entite, @arrete, @cote, @m2, @par);
        THROW 50041, @m2, 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- La ligne du compte vise.
        INSERT INTO dbo.ecriture_brouillon
            (entite, arrete, feuille_cote, question_id, journal_code,
             compte_num, libelle, debit, credit, saisi_par)
        VALUES (@entite, @arrete, @cote, @question, 'ODR', @compte, @libelle,
                CASE WHEN @sens = 'DEBIT'  THEN @montant ELSE 0 END,
                CASE WHEN @sens = 'CREDIT' THEN @montant ELSE 0 END,
                @par);
        -- La contrepartie, en sens inverse. En mode par ligne elle est
        -- facultative : le reviseur peut saisir les autres lignes a la main.
        IF @contrepartie IS NOT NULL
        BEGIN
            INSERT INTO dbo.ecriture_brouillon
                (entite, arrete, feuille_cote, question_id, journal_code,
                 compte_num, libelle, debit, credit, saisi_par)
            VALUES (@entite, @arrete, @cote, @question, 'ODR', @contrepartie,
                    @libelle,
                    CASE WHEN @sens = 'CREDIT' THEN @montant ELSE 0 END,
                    CASE WHEN @sens = 'DEBIT'  THEN @montant ELSE 0 END,
                    @par);
        END;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @m3 NVARCHAR (2000) =
            N'Generation refusee. Motif rendu par la base : '
          + LEFT(ERROR_MESSAGE(), 400);
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_generer_depuis_intention', @entite, @arrete, @cote,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW 50041, @m3, 1;
    END CATCH;
END;

GO

