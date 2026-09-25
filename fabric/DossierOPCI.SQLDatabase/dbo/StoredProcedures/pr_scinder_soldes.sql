
-- --- 2 : la scission, a blanc par defaut ----------------------------
CREATE   PROCEDURE dbo.pr_scinder_soldes
    @entite  VARCHAR (20),
    @a_blanc BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ecriture_id, compte_modele, compte_actuel, compte_cible,
           ISNULL(comp_aux_num, N'(vide)') AS auxiliaire,
           debit_part, credit_part, rang, parts
    FROM dbo.v_solde_a_scinder
    WHERE entite = @entite AND parts > 1
    ORDER BY ecriture_id, rang;

    IF @a_blanc = 1
    BEGIN
        SELECT N'A BLANC, RIEN N''EST ECRIT' AS mode,
               (SELECT COUNT(DISTINCT ecriture_id) FROM dbo.v_solde_a_scinder
                WHERE entite = @entite AND parts > 1) AS ecritures_a_scinder;
        RETURN;
    END;

    BEGIN TRANSACTION;
    BEGIN TRY
        -- TOUT SE FAIT EN UN SEUL ORDRE. Le declencheur
        -- tr_lot_equilibre verifie l equilibre du lot a CHAQUE
        -- instruction : inserer les nouvelles parts puis reduire la
        -- premiere laisserait le lot desequilibre entre les 2, et le
        -- refus tomberait. Un MERGE porte l insertion et la mise a jour
        -- ensemble.
        MERGE dbo.ecriture AS cible
        USING (SELECT * FROM dbo.v_solde_a_scinder
               WHERE entite = @entite AND parts > 1) AS src
        ON cible.id = src.ecriture_id AND src.rang = 1
        WHEN MATCHED THEN UPDATE SET
            compte_num = src.compte_cible,
            comp_aux_num = src.comp_aux_num,
            debit = src.debit_ajuste,
            credit = src.credit_ajuste
        WHEN NOT MATCHED BY TARGET THEN INSERT
            (lot_id, journal_code, journal_lib, ecriture_num, ecriture_date,
             compte_num, compte_lib, comp_aux_num, ecriture_lib,
             debit, credit, famille)
            VALUES (src.lot_id, src.journal_code, src.journal_lib, 'DET',
                    src.ecriture_date, src.compte_cible, src.compte_lib,
                    src.comp_aux_num, src.ecriture_lib,
                    src.debit_ajuste, src.credit_ajuste, src.famille);

        DECLARE @n INT = @@ROWCOUNT;
        COMMIT TRANSACTION;
        SELECT @n AS ecritures_scindees;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

