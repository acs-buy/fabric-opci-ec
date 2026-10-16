
-- 332-1, distributions et capitalisation par part (oracle, a_332_1_distributions), en fin de table.
CREATE   PROCEDURE dbo.pr_ann_a_332_1_distributions @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @an INT = dbo.fn_ann_annee(@c, @a), @k INT = 1;
    WHILE @k <= 5
    BEGIN
        DECLARE @y INT = @an - (@k - 1);
        IF @k = 1
        BEGIN
            EXEC dbo.pr_ann_par_part @c = @c, @a = @a, @code = 'DIST_RESULTAT', @k = 1, @termes = N'1|335-12|I_A_1|1', @unitaires = N'335-12|ACPT_N_TOTAL|3',
                 @formule = N'335-12 I_A_1[1] / NB_PARTS[1] + 335-12 ACPT_N_TOTAL[3]',
                 @source = N'affectation proposée (335-12) par part de la clôture, plus le montant unitaire des acomptes versés au titre de l’exercice (335-12, ligne Total acomptes, colonne 3)';
            EXEC dbo.pr_ann_par_part @c = @c, @a = @a, @code = 'DIST_CESSION', @k = 1, @termes = N'1|335-12|II_A_1|1', @unitaires = N'335-12|ACPT_N_TOTAL|5',
                 @formule = N'335-12 II_A_1[1] / NB_PARTS[1] + 335-12 ACPT_N_TOTAL[5]',
                 @source = N'affectation proposée (335-12) par part de la clôture, plus le montant unitaire des acomptes versés au titre de l’exercice (335-12, ligne Total acomptes, colonne 5)';
        END;
        ELSE
            EXEC dbo.pr_ann_distributions_de @c = @c, @a = @a, @k = @k, @y = @y;
        EXEC dbo.pr_ann_capitalisation @c = @c, @a = @a, @k = @k, @y = @y;
        SET @k += 1;
    END;
END;

GO

