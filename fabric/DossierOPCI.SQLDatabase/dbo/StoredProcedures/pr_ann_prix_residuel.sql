
-- ------------------------------------------------------------------------------------------------- 334-3
-- Revision 12 : les 3 echeances du prix d'achat residuel (article 334-3, p. 100), chacune a remplir (@mode 'AR', avec
-- @motif) ou nulle sans contrat (@mode 'ZERO', avec @source), puis PRIX_RESIDUEL, leur total (regle T, nature calcul).
CREATE   PROCEDURE dbo.pr_ann_prix_residuel @c INT, @a VARCHAR (20), @mode VARCHAR (4), @motif NVARCHAR (MAX) = NULL, @source NVARCHAR (MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @e TABLE (n INT, code VARCHAR (24), libelle NVARCHAR (200), ordre DECIMAL (19, 6));
    INSERT INTO @e VALUES (1, 'PRIX_RESIDUEL_1AN', N'Prix d''achat résiduel, à un an au plus', 7.1),
                          (2, 'PRIX_RESIDUEL_1_5ANS', N'Prix d''achat résiduel, à plus d''un an et cinq ans au plus', 7.2),
                          (3, 'PRIX_RESIDUEL_5ANS', N'Prix d''achat résiduel, à plus de cinq ans', 7.3);
    DECLARE @code VARCHAR (24), @lib NVARCHAR (200), @od DECIMAL (19, 6);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code, libelle, ordre FROM @e ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code, @lib, @od;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @mode = 'ZERO'
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = '334-3', @ligne = @code, @col = 1, @etat = 'CALCULE', @valeur = 0, @source = @source,
                 @regle = 'A334_3', @libelle = @lib, @ordre = @od;
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '334-3', @ligne = @code, @col = 1, @motif = @motif, @regle = 'A334_3', @libelle = @lib, @ordre = @od;
        FETCH NEXT FROM cur INTO @code, @lib, @od;
    END;
    CLOSE cur; DEALLOCATE cur;
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = '334-3', @ligne = N'PRIX_RESIDUEL', @col = 1,
         @termes = N'1|334-3|PRIX_RESIDUEL_1AN|1;1|334-3|PRIX_RESIDUEL_1_5ANS|1;1|334-3|PRIX_RESIDUEL_5ANS|1',
         @formule = N'PRIX_RESIDUEL_1AN[1] + PRIX_RESIDUEL_1_5ANS[1] + PRIX_RESIDUEL_5ANS[1]';
END;

GO

