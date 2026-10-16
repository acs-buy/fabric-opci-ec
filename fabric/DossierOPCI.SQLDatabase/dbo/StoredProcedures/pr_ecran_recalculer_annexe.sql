
-- Le bouton « Recalculer » de l'ecran (contrat, 3.1, point 4).
CREATE   PROCEDURE dbo.pr_ecran_recalculer_annexe @entite VARCHAR (20), @arrete VARCHAR (20), @par NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @r TABLE (calcul_id INT, calcule_le DATETIME2 (3), cellules INT, cellules_changees INT, a_remplir INT, en_attente INT,
                      versions_creees NVARCHAR (MAX), documents_perimes INT, arretes_recalcules NVARCHAR (MAX), message NVARCHAR (MAX));
    INSERT INTO @r EXEC dbo.pr_calculer_annexe @entite = @entite, @arrete = @arrete, @declencheur = 'BOUTON', @par = @par;
    SELECT message FROM @r;
END;

GO

