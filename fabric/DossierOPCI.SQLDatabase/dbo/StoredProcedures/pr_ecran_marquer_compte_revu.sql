
-- pr_ecran_marquer_compte_revu : 2 refus
-- ------------------------------------------------------------------ n° 8 : le compte revu
-- ref_croisee porte l'etat du compte que v_balance lit ; un compte revu se rattache a la feuille de valorisation (VALO) du
-- vehicule a l'arrete, la plus recente.
CREATE   PROCEDURE dbo.pr_ecran_marquer_compte_revu
    @vehicule VARCHAR (20),
    @arrete   VARCHAR (20),
    @compte   VARCHAR (20),
    @par      NVARCHAR (400),
    @xref     VARCHAR (30) = NULL   -- 10/10/2026 : la feuille choisie ; sans elle, la feuille VALO la plus recente
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @r NVARCHAR (1000) = dbo.fn_e3_refus_commun(@vehicule, @arrete, @par), @m NVARCHAR (1000);
    IF @r IS NOT NULL EXEC dbo.pr_e3_refuser @r;
    IF NULLIF(LTRIM(RTRIM(@compte)), '') IS NULL
        THROW 50770, N'Choisissez le compte dans la balance.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.v_balance WHERE entite = @vehicule AND arrete = @arrete AND compte = @compte)
    BEGIN
        SET @m = N'Le compte ' + @compte + N' n''est pas à la balance du véhicule à cet arrêté.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50771, @m, 1; END
    END;
    SET @xref = NULLIF(LTRIM(RTRIM(@xref)), '');
    IF @xref IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @xref AND entite = @vehicule AND arrete = @arrete)
    BEGIN
        SET @m = N'La feuille ' + @xref + N' n''est pas une feuille du véhicule à cet arrêté.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50773, @m, 1; END
    END;
    IF @xref IS NULL
        SET @xref = (SELECT TOP (1) cote FROM dbo.feuille_travail
                     WHERE entite = @vehicule AND arrete = @arrete AND cycle = 'VALO' ORDER BY prepare_le DESC, cote);
    IF @xref IS NULL
        THROW 50772, N'Aucune feuille de valorisation n''existe pour ce véhicule à cet arrêté : un compte revu se rattache à une feuille.', 1;
    DECLARE @deja VARCHAR (30) = (SELECT xref FROM dbo.ref_croisee WHERE entite = @vehicule AND arrete = @arrete AND compte_num = @compte AND etat = 'CONCLUE');
    IF @deja IS NOT NULL
    BEGIN
        SELECT @vehicule AS vehicule, N'Le compte ' + @compte + N' est déjà revu (feuille ' + @deja + N').' AS message;
        RETURN;
    END;
    UPDATE dbo.ref_croisee SET xref = @xref, etat = 'CONCLUE', par = @par, date_etat = SYSUTCDATETIME()
     WHERE entite = @vehicule AND arrete = @arrete AND compte_num = @compte;
    IF @@ROWCOUNT = 0
        INSERT INTO dbo.ref_croisee (arrete, entite, compte_num, xref, etat, par, date_etat)
        VALUES (@arrete, @vehicule, @compte, @xref, 'CONCLUE', @par, SYSUTCDATETIME());
    SELECT @vehicule AS vehicule, N'Compte ' + @compte + N' revu, rattaché à la feuille ' + @xref + N'.' AS message;
END;

GO

