
CREATE   PROCEDURE dbo.pr_traduire_entite
    @entite  VARCHAR (20),
    @a_blanc BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT compte_ecrit, ISNULL(comp_aux_num, N'(vide)') AS auxiliaire,
           est_interne, compte_cible, COUNT(*) AS ecritures,
           SUM(debit) AS debit, SUM(credit) AS credit
    FROM dbo.v_ecriture_a_traduire
    WHERE entite = @entite
    GROUP BY compte_ecrit, comp_aux_num, est_interne, compte_cible
    ORDER BY compte_ecrit, est_interne;

    IF @a_blanc = 1
    BEGIN
        SELECT N'A BLANC, RIEN N''EST ECRIT' AS mode,
               (SELECT COUNT(*) FROM dbo.v_ecriture_a_traduire
                WHERE entite = @entite)              AS ecritures_a_traduire;
        RETURN;
    END;

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE e
        SET compte_num = t.compte_cible,
            compte_lib = LEFT(ISNULL(t.libelle_cible, e.compte_lib), 200)
        FROM dbo.ecriture e
        JOIN dbo.v_ecriture_a_traduire t ON t.ecriture_id = e.id
        WHERE t.entite = @entite;

        DECLARE @n INT = @@ROWCOUNT;
        UPDATE dbo.ref_entite SET plan_propre_en_service = 1
        WHERE code = @entite;
        COMMIT TRANSACTION;

        SELECT @n AS ecritures_traduites,
               N'l''entité lit désormais son propre plan' AS lecture;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

