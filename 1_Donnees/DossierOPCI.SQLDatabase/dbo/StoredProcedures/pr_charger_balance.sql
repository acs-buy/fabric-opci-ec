
-- --- 2 : pr_charger_balance, du transit vers un lot -----------------
-- Une ligne d'ecriture par compte, au journal de reprise, datee de
-- l'arrete. C'est le point P7 de la specification.
CREATE   PROCEDURE dbo.pr_charger_balance
    @import_id INT,
    @par       NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @entite VARCHAR (20), @arrete VARCHAR (20), @format VARCHAR (10),
            @statut VARCHAR (20), @date_arrete DATE, @lot INT;
    SELECT @entite = i.entite, @arrete = i.arrete, @format = i.format,
           @statut = i.statut
    FROM dbo.import_fec i WHERE i.id = @import_id;
    SELECT @date_arrete = date_arrete FROM dbo.ref_arrete
    WHERE entite = @entite AND arrete = @arrete;

    BEGIN TRY
        IF @entite IS NULL
            THROW 50065, 'Chargement refuse : cet import n''existe pas au carnet.', 1;
        IF @format <> 'BALANCE'
            THROW 50065, 'Chargement refuse : cet import n''est pas au format BALANCE. Le fichier des ecritures se charge par dbo.pr_charger_import_fec.', 1;
        IF @statut <> 'EN_COURS'
            THROW 50065, 'Chargement refuse : cet import n''est pas au statut EN_COURS. Un import charge ou rejete ne se recharge pas, il se reprend par une nouvelle inscription.', 1;

        -- Garde 1 : le transit porte des lignes pour cet import.
        IF NOT EXISTS (SELECT 1 FROM dbo.stg_balance
                       WHERE import_id = @import_id AND recevable = 1)
            THROW 50065, 'Chargement refuse : aucune ligne recevable dans le transit de balance pour cet import.', 1;

        -- Garde 2 : tout compte recevable a sa traduction. Sans elle, la
        -- jointure de rattachement ecarterait la ligne en silence.
        IF EXISTS (
            SELECT 1 FROM dbo.stg_balance s
            WHERE s.import_id = @import_id AND s.recevable = 1
              AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite r
                              WHERE r.entite = s.entite
                                AND r.compte_entite = s.compte_entite)
        )
        BEGIN
            DECLARE @liste NVARCHAR (600) =
                (SELECT STRING_AGG(CAST(x.c AS NVARCHAR (24)), N', ')
                 FROM (SELECT DISTINCT TOP 20 s.compte_entite AS c
                       FROM dbo.stg_balance s
                       WHERE s.import_id = @import_id AND s.recevable = 1
                         AND NOT EXISTS (SELECT 1 FROM dbo.ref_compte_entite r
                                         WHERE r.entite = s.entite
                                           AND r.compte_entite = s.compte_entite)
                      ) AS x);
            DECLARE @m2 NVARCHAR (2000) =
                N'Chargement refuse : des comptes de la balance n''ont aucune '
              + N'traduction dans dbo.ref_compte_entite et seraient ecartes '
              + N'en silence. Comptes en cause : '
              + COALESCE(@liste, N'liste indisponible')
              + N'. Completer le rattachement, article 411-1.';
            THROW 50065, @m2, 1;
        END;

        -- Garde 3 : la balance est equilibree. Une balance qui ne l'est pas
        -- n'est pas une balance.
        DECLARE @ecart DECIMAL (19,2) =
            (SELECT CAST(SUM(solde_debiteur) - SUM(solde_crediteur)
                         AS DECIMAL (19,2))
             FROM dbo.stg_balance
             WHERE import_id = @import_id AND recevable = 1);
        IF @ecart <> 0
        BEGIN
            DECLARE @m3 NVARCHAR (2000) =
                N'Chargement refuse : la balance n''est pas equilibree, '
              + N'l''ecart entre les soldes debiteurs et crediteurs est de '
              + CAST(@ecart AS NVARCHAR (30)) + N'.';
            THROW 50065, @m3, 1;
        END;

        BEGIN TRANSACTION;
        -- Le lot, famille IMPORTEE, qui porte son identifiant d'import :
        -- la contrainte ck_lot_source_par_famille l'exige.
        INSERT INTO dbo.lot_ecritures
            (arrete, famille, portee, entite, statut, motif, import_id,
             cree_par, statut_par, statut_le)
        VALUES (@arrete, 'IMPORTEE', 'ENTITE', @entite, 'VALIDE',
                N'Balance chargee du transit, import '
                + CAST(@import_id AS NVARCHAR (20)),
                @import_id, @par, @par, SYSUTCDATETIME());
        SET @lot = CAST(SCOPE_IDENTITY() AS INT);

        -- Une ecriture de solde par compte, traduite au plan du modele,
        -- au journal de reprise et datee de l'arrete.
        INSERT INTO dbo.ecriture
            (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
             compte_num, compte_lib, ecriture_lib, debit, credit, famille)
        SELECT @lot, 'AN', N'A nouveaux et reprise de balance', 'BAL',
               @date_arrete, r.compte_modele,
               COALESCE(m.libelle, s.libelle_entite),
               N'Solde de reprise, compte ' + s.compte_entite
                   + COALESCE(N' ' + s.libelle_entite, N''),
               s.solde_debiteur, s.solde_crediteur, 'IMPORTEE'
        FROM dbo.stg_balance s
        JOIN dbo.ref_compte_entite r ON r.entite = s.entite
                                    AND r.compte_entite = s.compte_entite
        LEFT JOIN dbo.ref_compte m ON m.compte = r.compte_modele
        WHERE s.import_id = @import_id AND s.recevable = 1;

        -- Les lignes rejetees du transit passent dans la table perenne.
        INSERT INTO dbo.rejet_import
            (import_id, nature, numero_ligne, compte_num, debit, credit,
             motif, geste)
        SELECT s.import_id, 'LIGNE', s.numero_ligne, s.compte_entite,
               s.solde_debiteur, s.solde_crediteur,
               COALESCE(s.motif_rejet, N'Ligne declaree non recevable par le transit.'),
               N'Corriger la ligne dans le classeur source, puis reprendre l''import.'
        FROM dbo.stg_balance s
        WHERE s.import_id = @import_id AND s.recevable = 0
          AND NOT EXISTS (SELECT 1 FROM dbo.rejet_import r
                          WHERE r.import_id = s.import_id
                            AND r.numero_ligne = s.numero_ligne);

        UPDATE dbo.import_fec
           SET statut = 'CHARGE',
               lignes_lues = (SELECT COUNT(*) FROM dbo.stg_balance
                              WHERE import_id = @import_id),
               lignes_rejetees = (SELECT COUNT(*) FROM dbo.stg_balance
                                  WHERE import_id = @import_id AND recevable = 0)
         WHERE id = @import_id;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        INSERT INTO dbo.rejet_import
            (import_id, nature, motif, motif_arret, geste)
        SELECT @import_id, 'FICHIER', LEFT(ERROR_MESSAGE(), 800),
               N'Refus au chargement de la balance.',
               N'Lire le motif, corriger, puis recharger.'
        WHERE EXISTS (SELECT 1 FROM dbo.import_fec WHERE id = @import_id);
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_charger_balance', @entite, @arrete,
                LEFT(ERROR_MESSAGE(), 2000), @par);
        THROW;
    END CATCH;
END

GO

