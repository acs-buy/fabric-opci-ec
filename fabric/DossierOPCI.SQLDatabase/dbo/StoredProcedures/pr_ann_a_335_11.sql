
-- 335-11 : engagements hors bilan.
CREATE   PROCEDURE dbo.pr_ann_a_335_11 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = '335-11', @ligne = N'IFT', @col = 1, @motif = N'rubrique', @regle = 'RC1', @fmt = 'texte';
    DECLARE @code VARCHAR (24);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT code FROM (VALUES (1, 'INVESTISSEMENTS'), (2, 'IFT_REGLEMENTES'), (3, 'IFT_GRE_A_GRE'), (4, 'IFT_AUTRES')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '335-11', @ligne = @code, @col = 1,
             @motif = N'engagements hors bilan, absents de la base', @fmt = 'texte', @nature = 'texte',
             @obligation = 'CONDITIONNELLE', @regle = 'TXT';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

