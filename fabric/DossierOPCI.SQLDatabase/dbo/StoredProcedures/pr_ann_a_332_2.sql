
-- 332-2 : les mentions du reglement ANC n° 2020-07, puis chaque ligne de l'article, a remplir.
CREATE   PROCEDURE dbo.pr_ann_a_332_2 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '332-2', @ligne = N'MENTIONS_2020_07', @col = 1,
         @motif = N'mentions du règlement ANC n° 2020-07, sans source en base', @fmt = 'texte', @nature = 'texte',
         @regle = 'NEUVE', @libelle = N'Mentions relatives aux règles et méthodes comptables prévues par le règlement ANC n° 2020-07 relatif aux comptes annuels des organismes de placement collectif à capital variable',
         @ordre = 0;
    DECLARE @code VARCHAR (24);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM dbo.ref_ligne_annexe WHERE article = '332-2' ORDER BY ordre;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '332-2', @ligne = @code, @col = 1,
             @motif = N'information de l’article 332-2, sans source en base', @fmt = 'texte', @nature = 'texte', @regle = 'RC5';
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

