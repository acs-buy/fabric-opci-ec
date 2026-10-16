
-- Le calcul de toutes les tables de l'entite, dans l'ordre des dates, dans les tables de travail.
CREATE   PROCEDURE dbo.pr_ann_calculer_travail @c INT, @entite VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    SET ANSI_WARNINGS OFF;
    DELETE dbo.annexe_w_ops WHERE calcul_id = @c;
    DELETE dbo.annexe_w_cel WHERE calcul_id = @c;
    DELETE dbo.annexe_w_ctl WHERE calcul_id = @c;
    EXEC dbo.pr_ann_charger @c = @c, @entite = @entite;
    DECLARE @a VARCHAR (20);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT arrete FROM dbo.annexe_w_arr WHERE calcul_id = @c AND mission = 1 ORDER BY date_arrete, arrete;
    OPEN cur; FETCH NEXT FROM cur INTO @a;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_calculer_arrete @c = @c, @a = @a;
        FETCH NEXT FROM cur INTO @a;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

