
-- CELLE QUI RELANCE L'ERREUR, apres avoir ecrit le meme message.
CREATE   PROCEDURE dbo.pr_essai_refus_relance
    @id int = 1
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        THROW 50002, N'REFUS METIER D''ESSAI : cette action est impossible dans cet etat.', 1;
    END TRY
    BEGIN CATCH
        DECLARE @m nvarchar(2000) = ERROR_MESSAGE();
        UPDATE dbo.essai_saisie_grille
           SET libelle = N'REFUS relance : ' + LEFT(@m, 100)
         WHERE id = @id;
        THROW 50003, @m, 1;
    END CATCH;
END;

GO

