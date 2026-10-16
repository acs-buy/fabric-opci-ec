CREATE   PROCEDURE dbo.pr_ann_a_335_7 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_ann_ligne_335_7 @c = @c, @a = @a, @code = 'PRODUITS_IMMO', @ligne_cr = 'R_PI_1', @detail = 'produits', @toujours = 1;
    EXEC dbo.pr_ann_ligne_335_7 @c = @c, @a = @a, @code = 'CHARGES_IMMO', @ligne_cr = 'R_CI_1', @detail = 'charges', @toujours = 1;
    EXEC dbo.pr_ann_ligne_335_7 @c = @c, @a = @a, @code = 'PRODUITS_PARTS', @ligne_cr = 'R_PI_2', @detail = NULL, @toujours = 0;
    EXEC dbo.pr_ann_ligne_335_7 @c = @c, @a = @a, @code = 'CHARGES_PARTS', @ligne_cr = 'R_CI_2', @detail = NULL, @toujours = 0;
    EXEC dbo.pr_ann_ligne_335_7 @c = @c, @a = @a, @code = 'PRODUITS_AUTRES', @ligne_cr = 'R_PI_3', @detail = NULL, @toujours = 0;
    EXEC dbo.pr_ann_ligne_335_7 @c = @c, @a = @a, @code = 'CHARGES_AUTRES', @ligne_cr = 'R_CI_3', @detail = NULL, @toujours = 0;
    DECLARE @code VARCHAR (24);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM (VALUES (1, 'ANTERIEURS'), (2, 'EXCEPTIONNELS'), (3, 'REMBOURSEMENTS')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '335-7', @ligne = @code, @col = 1, @motif = N'aucune ligne du compte de résultat ne les isole',
             @fmt = 'texte', @nature = 'texte', @obligation = 'CONDITIONNELLE', @regle = 'TXT';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

