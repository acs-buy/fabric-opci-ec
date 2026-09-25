
-- --- 4 : charger un import, en une procedure --------------------------
-- Reprise des blocs 2, 3, 5, 6, 7 et 8 de 11_chargement.sql, avec toutes
-- leurs gardes. Les lignes doivent deja etre dans stg_fec, sous leur
-- reference d'import, et leur recevabilite deja posee.
CREATE   PROCEDURE dbo.pr_charger_import_fec
    @reference_import VARCHAR (100),
    @arrete           VARCHAR (20),
    @exercice_debut   DATE,
    @exercice_fin     DATE,
    @nom_fichier      NVARCHAR (400),
    @empreinte        VARCHAR (64),
    @par              NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @lues INT, @rejetees INT;
    SELECT @entite = MAX(entite), @lues = COUNT(*),
           @rejetees = SUM(CASE WHEN recevable = 0 THEN 1 ELSE 0 END)
    FROM dbo.stg_fec
    WHERE reference_import = @reference_import AND import_id IS NULL;

    IF @entite IS NULL
    BEGIN
        DECLARE @m0 NVARCHAR (2000) =
            N'Chargement refuse : aucune ligne en attente sous la reference '
          + @reference_import + N'.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_charger_import_fec', NULL, @arrete, NULL, @m0, @par);
        THROW 50043, @m0, 1;
    END;
    IF EXISTS (SELECT 1 FROM dbo.stg_fec
               WHERE reference_import = @reference_import
                 AND import_id IS NULL
               GROUP BY reference_import HAVING COUNT(DISTINCT entite) > 1)
    BEGIN
        DECLARE @m0b NVARCHAR (2000) =
            N'Chargement refuse : la reference ' + @reference_import
          + N' porte des lignes de plusieurs entites. Un import porte une '
          + N'entite et une seule.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_charger_import_fec', @entite, @arrete, NULL, @m0b, @par);
        THROW 50043, @m0b, 1;
    END;

    DECLARE @imp INT, @lot INT;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- Bloc 2 : l'entete de l'import.
        INSERT INTO dbo.import_fec
            (entite, arrete, nom_fichier, empreinte, exercice_debut,
             exercice_fin, lignes_lues, lignes_rejetees, statut, importe_par)
        VALUES (@entite, @arrete, @nom_fichier, @empreinte, @exercice_debut,
                @exercice_fin, @lues, @rejetees, 'EN_COURS', @par);
        SET @imp = CAST(SCOPE_IDENTITY() AS INT);
        -- Bloc 3 : les lignes portent desormais leur identifiant.
        UPDATE dbo.stg_fec SET import_id = @imp
        WHERE reference_import = @reference_import AND import_id IS NULL;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        DECLARE @m1 NVARCHAR (2000) =
            N'Chargement refuse a la creation de l''entete. Motif rendu par '
          + N'la base : ' + LEFT(ERROR_MESSAGE(), 400);
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_charger_import_fec', @entite, @arrete, NULL,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW 50043, @m1, 1;
    END CATCH;

    -- Garde du bloc 6 : aucun compte recevable hors du rattachement.
    IF EXISTS (SELECT 1 FROM dbo.v_comptes_non_rattaches WHERE import_id = @imp)
    BEGIN
        DECLARE @liste NVARCHAR (600) =
            (SELECT STRING_AGG(CAST(x.compte AS NVARCHAR (24)), N', ')
             FROM (SELECT DISTINCT TOP 20 compte_num AS compte
                   FROM dbo.v_comptes_non_rattaches
                   WHERE import_id = @imp) AS x);
        DECLARE @m2 NVARCHAR (2000) =
            N'Chargement refuse : des ecritures recevables portent un compte '
          + N'absent de ref_compte_entite et seraient ecartees en silence par '
          + N'la jointure de rattachement. Comptes en cause : '
          + COALESCE(@liste, N'liste indisponible')
          + N'. Completer le rattachement, article 411-1.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_charger_import_fec', @entite, @arrete, NULL, @m2, @par);
        THROW 50043, @m2, 1;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;
        -- Bloc 5 : le lot, famille importee, balance B0 au prix de revient.
        -- La contrainte ck_lot_source_par_famille, posee par le script 56,
        -- exige l'identifiant d'import sur un lot de famille importee.
        INSERT INTO dbo.lot_ecritures
            (arrete, famille, portee, entite, statut, version_regles, motif,
             import_id, cree_par, statut_par, statut_le)
        VALUES (@arrete, 'IMPORTEE', 'ENTITE', @entite, 'VALIDE', NULL,
                N'Import du fichier des ecritures comptables : '
                    + LEFT(@nom_fichier, 352),
                @imp, @par, @par, SYSUTCDATETIME());
        SET @lot = CAST(SCOPE_IDENTITY() AS INT);
        -- Bloc 6 : les ecritures, en une seule instruction, le declencheur
        -- d'equilibre l'exigeant. compte_origine garde le compte du fichier.
        INSERT INTO dbo.ecriture
            (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
             compte_num, compte_lib, comp_aux_num, comp_aux_lib,
             piece_ref, piece_date, ecriture_lib, debit, credit,
             ecriture_let, date_let, valid_date, montant_devise, id_devise,
             compte_origine, famille)
        SELECT @lot, s.journal_code, s.journal_lib, s.ecriture_num,
               s.ecriture_date, r.compte_modele, s.compte_lib,
               s.comp_aux_num, s.comp_aux_lib, s.piece_ref, s.piece_date,
               s.ecriture_lib, s.debit, s.credit, s.ecriture_let, s.date_let,
               s.valid_date, s.montant_devise, s.id_devise, s.compte_num,
               'IMPORTEE'
        FROM dbo.stg_fec s
        JOIN dbo.ref_compte_entite r ON r.entite = s.entite
                                    AND r.compte_entite = s.compte_num
        WHERE s.import_id = @imp AND s.recevable = 1;
        -- Bloc 7 : l'axe entite sur toutes les ecritures du lot.
        INSERT INTO dbo.ecriture_axe (ecriture_id, entite)
        SELECT e.id, @entite FROM dbo.ecriture e
        WHERE e.lot_id = @lot
          AND NOT EXISTS (SELECT 1 FROM dbo.ecriture_axe a
                          WHERE a.ecriture_id = e.id);
        -- Bloc 8 : clore l'import.
        UPDATE dbo.import_fec SET statut = 'CHARGE' WHERE id = @imp;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        UPDATE dbo.import_fec SET statut = 'REJETE' WHERE id = @imp;
        DECLARE @m3 NVARCHAR (2000) =
            N'Chargement refuse, aucune ecriture n''est ecrite. Motif rendu '
          + N'par la base : ' + LEFT(ERROR_MESSAGE(), 400);
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_charger_import_fec', @entite, @arrete, NULL,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW 50043, @m3, 1;
    END CATCH;

    SELECT @imp AS import_id, @lot AS lot_id, @entite AS entite;
END;

GO

