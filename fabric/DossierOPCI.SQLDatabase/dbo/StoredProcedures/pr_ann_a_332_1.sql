
CREATE   PROCEDURE dbo.pr_ann_a_332_1 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '332-1';
    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'STRATEGIE', @col = 1, @motif = N'stratégie du prospectus, sans source en base',
         @fmt = 'texte', @nature = 'texte', @regle = 'A332_1';
    DECLARE @an INT = dbo.fn_ann_annee(@c, @a), @dn DATE = dbo.fn_ann_date(@c, @a), @k INT = 1;
    WHILE @k <= 5
    BEGIN
        DECLARE @y INT = @an - (@k - 1);
        DECLARE @x VARCHAR (20) = dbo.fn_ann_annuel_de(@c, @y, @dn), @x2 VARCHAR (20), @v DECIMAL (38, 12) = NULL, @src NVARCHAR (400) = N'', @m NVARCHAR (400);
        DECLARE @sid INT = dbo.fn_ann_saisie_annee(@c, @a, N'ACTIF_NET', @y);
        IF @x IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @x AND mission = 1) AND dbo.fn_ann_E(@c, @x, 'P_CP', 1) IS NOT NULL
            SELECT @v = dbo.fn_ann_E(@c, @x, 'P_CP', 1), @src = N'bilan, ligne ' + dbo.fn_ann_nom_etat('P_CP') + N', exercice N, arrêté du ' + dbo.fn_ann_arrete_fr(@c, @x);
        ELSE
        BEGIN
            SET @x2 = dbo.fn_ann_annuel_de(@c, @y + 1, @dn);
            IF @x2 IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @x2 AND mission = 1) AND dbo.fn_ann_E(@c, @x2, 'P_CP', 2) IS NOT NULL
                SELECT @v = dbo.fn_ann_E(@c, @x2, 'P_CP', 2), @src = N'bilan, ligne ' + dbo.fn_ann_nom_etat('P_CP') + N', exercice N-1, arrêté du ' + dbo.fn_ann_arrete_fr(@c, @x2);
        END;
        IF @v IS NULL
        BEGIN
            SET @m = N'exercice ' + CAST(@y AS NVARCHAR (4)) + N' sans bilan en base';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'ACTIF_NET', @col = @k, @motif = @m, @nature = 'etat', @regle = 'A332_1', @saisie_id = @sid;
        END;
        ELSE
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'ACTIF_NET', @col = @k, @etat = 'LU', @valeur = @v, @source = @src, @nature = 'etat',
                 @regle = 'A332_1', @saisie_id = @sid;
        DECLARE @p DECIMAL (38, 12) = CASE WHEN @x IS NOT NULL THEN dbo.fn_ann_parts(@c, @x) END;
        SET @sid = dbo.fn_ann_saisie_annee(@c, @a, N'NB_PARTS', @y);
        IF @p IS NULL
        BEGIN
            SET @m = N'parts de l’exercice ' + CAST(@y AS NVARCHAR (4)) + N' absentes de la base';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'NB_PARTS', @col = @k, @motif = @m, @fmt = 'nombre', @regle = 'A332_1', @saisie_id = @sid;
        END;
        ELSE
        BEGIN
            SET @src = N'registre des porteurs, parts en circulation au ' + dbo.fn_ann_arrete_fr(@c, @x);
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'NB_PARTS', @col = @k, @etat = 'LU', @valeur = @p, @fmt = 'nombre', @source = @src,
                 @regle = 'A332_1', @saisie_id = @sid;
        END;
        DECLARE @an_ DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'ACTIF_NET', @k), @nb_ DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'NB_PARTS', @k);
        DECLARE @ops NVARCHAR (200) = N'332-1|ACTIF_NET|' + CAST(@k AS NVARCHAR (2)) + N';332-1|NB_PARTS|' + CAST(@k AS NVARCHAR (2));
        IF @an_ IS NOT NULL AND @nb_ IS NOT NULL AND @nb_ <> 0
        BEGIN
            DECLARE @vl DECIMAL (38, 12) = ROUND(CAST(CAST(@an_ AS DECIMAL (20, 2)) / CAST(@nb_ AS DECIMAL (18, 6)) AS DECIMAL (38, 12)), 2);
            DECLARE @f NVARCHAR (200) = N'ACTIF_NET[' + CAST(@k AS NVARCHAR (2)) + N'] / NB_PARTS[' + CAST(@k AS NVARCHAR (2)) + N']';
            DECLARE @s_vl NVARCHAR (MAX) = dbo.fn_ann_nom_ligne(@c, @a, @art, N'ACTIF_NET') + N' divisée par la ' + dbo.fn_ann_nom_ligne(@c, @a, @art, N'NB_PARTS') + N', même colonne';
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'VL_UNIT', @col = @k, @etat = 'CALCULE', @valeur = @vl, @source = @s_vl,
                 @formule = @f, @nature = 'calcul', @obligation = 'SANS', @regle = 'A332_1', @ops = @ops;
            DECLARE @vb DECIMAL (38, 12) = CASE WHEN @x IS NOT NULL THEN dbo.fn_ann_num(@c, 'VL', @x) END;
            IF @vb IS NOT NULL
            BEGIN
                DECLARE @e DECIMAL (38, 12) = @vl - @vb, @cle NVARCHAR (40) = N'colonne ' + CAST(@k AS NVARCHAR (2));
                EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S332_1_VL', @cle = @cle, @ecart = @e;
            END;
        END;
        ELSE IF @nb_ = 0
            EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'VL_UNIT', @col = @k, @motif = N'aucune part en circulation', @regle = 'A332_1';
        ELSE
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'VL_UNIT', @col = @k, @etat = 'EN_ATTENTE', @motif = N'actif net ou parts à remplir',
                 @nature = 'calcul', @obligation = 'SANS', @regle = 'RC4', @ops = @ops;
        SET @k += 1;
    END;
END;

GO

