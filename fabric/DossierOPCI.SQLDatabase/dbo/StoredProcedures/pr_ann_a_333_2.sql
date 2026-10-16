
-- ------------------------------------------------------------------------------------------------- 333-2
CREATE   PROCEDURE dbo.pr_ann_a_333_2 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '333-2';
    DECLARE @prev VARCHAR (20) = dbo.fn_ann_annuel_precedent(@c, @a);
    DECLARE @bas DATE = dbo.fn_ann_date(@c, @prev), @haut DATE = dbo.fn_ann_date(@c, @a);
    DECLARE @arrete_n BIT = CASE WHEN dbo.fn_ann_parts(@c, @a) IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @porteurs INT = dbo.fn_ann_nb_porteurs(@c);
    DECLARE @k INT = 1, @code VARCHAR (24), @nat VARCHAR (20), @rac VARCHAR (4), @sens INT;
    WHILE @k <= 2
    BEGIN
        IF @k = 1 SELECT @code = 'SOUSCRIPTIONS', @nat = 'SOUSCRIPTION', @rac = '1021', @sens = -1;
        ELSE SELECT @code = 'RACHATS', @nat = 'RACHAT', @rac = '1022', @sens = 1;
        IF @prev IS NULL OR @porteurs = 0 OR @arrete_n = 0
        BEGIN
            DECLARE @m NVARCHAR (400) = CASE WHEN @prev IS NULL OR @porteurs = 0 THEN N'registre des porteurs absent ou exercice sans borne'
                ELSE N'registre des porteurs non arrêté au ' + CONVERT(NVARCHAR (10), @haut, 103) + N' : aucun nombre de parts en circulation à cette date' END;
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 3, @motif = @m, @fmt = 'nombre', @regle = 'A333_2';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = @m, @fmt = 'montant', @regle = 'A333_2';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 4, @motif = @m, @fmt = 'montant', @regle = 'A333_2';
        END;
        ELSE
        BEGIN
            DECLARE @nb INT, @parts DECIMAL (38, 12), @mt DECIMAL (38, 12);
            SELECT @nb = COUNT(*), @parts = ISNULL(SUM(ISNULL(nombre_parts, 0)), 0), @mt = ISNULL(SUM(ISNULL(montant, 0)), 0)
            FROM dbo.fn_ann_mvt_porteur(@c, @nat, @bas, @haut);
            DECLARE @src NVARCHAR (400) = N'registre des porteurs, ' + CASE @nat WHEN 'SOUSCRIPTION' THEN N'souscriptions' ELSE N'rachats' END + N' du ' + CONVERT(NVARCHAR (10), @bas, 103) + N' exclu au ' + CONVERT(NVARCHAR (10), @haut, 103) + N' inclus';
            DECLARE @s3 NVARCHAR (400) = @src + N', nombre de parts', @s1 NVARCHAR (400) = @src + N', montant';
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 3, @etat = 'LU', @valeur = @parts, @fmt = 'nombre', @source = @s3, @regle = 'A333_2';
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = 'LU', @valeur = @mt, @source = @s1, @regle = 'A333_2';
            IF @nb = 0
            BEGIN
                DECLARE @s4 NVARCHAR (400) = CASE WHEN @code = 'SOUSCRIPTIONS'
                    THEN N'aucune souscription au registre sur l’exercice : aucune commission de souscription'
                    ELSE N'aucun rachat au registre sur l’exercice : aucune commission de rachat' END;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 4, @etat = 'CALCULE', @valeur = 0, @source = @s4, @regle = 'A333_2';
            END;
            ELSE
            BEGIN
                DECLARE @m4 NVARCHAR (600) = CAST(@nb AS NVARCHAR (10)) + N' ' + CASE @nat WHEN 'SOUSCRIPTION' THEN N'souscription' ELSE N'rachat' END + N'(s) au registre sur l’exercice : les frais et commissions acquis à l’OPCI ne sont enregistrés nulle part dans la base, et les 103 sont virés au 101 à la clôture (article 411-2, p. 108)';
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 4, @motif = @m4, @regle = 'A333_2';
            END;
            DECLARE @s DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, @rac, '', N'*', 0);
            IF @s IS NOT NULL AND @s <> 0
            BEGIN
                DECLARE @e DECIMAL (38, 12) = @mt - @sens * @s;
                EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S333_2_REGISTRE', @cle = @code, @ecart = @e;
            END;
        END;
        SET @k += 1;
    END;
    DECLARE @col TINYINT, @i INT = 1;
    WHILE @i <= 3
    BEGIN
        SET @col = CASE @i WHEN 1 THEN 3 WHEN 2 THEN 1 ELSE 4 END;
        DECLARE @t NVARCHAR (200) = N'1|333-2|SOUSCRIPTIONS|' + CAST(@col AS NVARCHAR (2)) + N';-1|333-2|RACHATS|' + CAST(@col AS NVARCHAR (2));
        DECLARE @f VARCHAR (10) = CASE WHEN @col = 3 THEN 'nombre' ELSE 'montant' END;
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'MONTANTS_NETS', @col = @col, @termes = @t, @fmt = @f;
        SET @i += 1;
    END;
    DECLARE @net DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'MONTANTS_NETS', 3);
    DECLARE @pn DECIMAL (38, 12) = dbo.fn_ann_parts(@c, @a), @pp DECIMAL (38, 12) = CASE WHEN @prev IS NOT NULL THEN dbo.fn_ann_parts(@c, @prev) END;
    IF @net IS NOT NULL AND @pn IS NOT NULL AND @pp IS NOT NULL
    BEGIN
        DECLARE @ep DECIMAL (38, 12) = @net - (@pn - @pp);
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S333_2_PARTS', @cle = N'parts', @ecart = @ep;
    END;
END;

GO

