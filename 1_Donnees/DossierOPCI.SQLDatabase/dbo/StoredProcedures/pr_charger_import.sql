
-- --- 3 : pr_charger_import, l'aiguillage par le format --------------
-- Un seul point d'entree pour l'ecran, quel que soit le format du
-- fichier. Le chemin FEC reste celui de dbo.pr_charger_import_fec, dont
-- le rejeu a eprouve les 200 lignes.
CREATE   PROCEDURE dbo.pr_charger_import
    @import_id INT,
    @par       NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @format VARCHAR (10) =
        (SELECT format FROM dbo.import_fec WHERE id = @import_id);
    IF @format IS NULL
        THROW 50066, 'Chargement refuse : cet import n''existe pas au carnet.', 1;
    IF @format = 'BALANCE'
        EXEC dbo.pr_charger_balance @import_id, @par;
    ELSE
        THROW 50066, 'Chargement refuse : le format FEC se charge par dbo.pr_charger_import_fec, qui prend une reference de transit et non un identifiant d''import. La scission de cette procedure attend que le fichier de rejeu soit au dossier, son decoupage a l''aveugle referait le seul chemin que le rejeu a eprouve.', 1;
END

GO

