
-- ------------------------------------------------------------------------------------------------- 333-1
CREATE   PROCEDURE dbo.pr_ann_acomptes_333_1 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @k INT = 1, @racine VARCHAR (4), @net VARCHAR (24), @pmv VARCHAR (24), @cn VARCHAR (4), @cp VARCHAR (4);
    WHILE @k <= 2
    BEGIN
        IF @k = 1 SELECT @racine = '129', @net = 'SD_AC_NET', @pmv = 'SD_AC_PMV', @cn = '1291', @cp = '1293';
        ELSE SELECT @racine = '198', @net = 'SD_REG_AC_NET', @pmv = 'SD_REG_AC_PMV', @cn = '1981', @cp = '1982';
        DECLARE @tout DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, @racine, '', N'*', 0);
        IF @tout IS NULL
        BEGIN
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '333-1', @ligne = @net, @col = 1, @motif = N'arrêté sans balance', @regle = 'A333_1';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '333-1', @ligne = @pmv, @col = 1, @motif = N'arrêté sans balance', @regle = 'A333_1';
        END;
        ELSE
        BEGIN
            DECLARE @scn DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, @cn, '', N'*', 0), @scp DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, @cp, '', N'*', 0);
            DECLARE @hors DECIMAL (38, 12) = @tout - @scn - @scp;
            DECLARE @j INT = 1, @code VARCHAR (24), @sc VARCHAR (4), @v DECIMAL (38, 12), @src NVARCHAR (200), @m NVARCHAR (400);
            WHILE @j <= 2
            BEGIN
                IF @j = 1 SELECT @code = @net, @sc = @cn, @v = -@scn; ELSE SELECT @code = @pmv, @sc = @cp, @v = -@scp;
                IF @hors = 0
                BEGIN
                    SET @src = N'solde créditeur du ' + @sc;
                    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = '333-1', @ligne = @code, @col = 1, @etat = 'LU', @valeur = @v,
                         @source = @src, @regle = 'A333_1';
                END;
                ELSE
                BEGIN
                    SET @m = N'le ' + @racine + N' porte ' + dbo.fn_ann_format('montant', @hors) + N' hors de ' + @cn + N' et ' + @cp;
                    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '333-1', @ligne = @code, @col = 1, @motif = @m, @regle = 'A333_1';
                END;
                SET @j += 1;
            END;
            DECLARE @codes NVARCHAR (100) = @net + N';' + @pmv, @parent DECIMAL (38, 12) = -@tout, @nom NVARCHAR (100) = N'solde créditeur du ' + @racine;
            EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = '333-1', @codes = @codes, @col = 1, @parent = @parent, @nom = @nom;
        END;
        SET @k += 1;
    END;
END;

GO

