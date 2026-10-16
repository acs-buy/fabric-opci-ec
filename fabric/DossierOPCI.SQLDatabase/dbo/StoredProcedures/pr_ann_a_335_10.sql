
-- ------------------------------------------------------------------------------------------------- 335-10
CREATE   PROCEDURE dbo.pr_ann_a_335_10 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @residu NVARCHAR (MAX) = N'résidu de la ligne ' + dbo.fn_ann_nom_etat('R_TVI') + N' du compte de résultat';
    DECLARE @art VARCHAR (10) = '335-10', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    EXEC dbo.pr_ann_lignes_racines @c = @c, @a = @a, @art = @art, @codes = 'F_1,F_2,F_5';
    DECLARE @noms NVARCHAR (MAX) = (SELECT MAX(CASE WHEN code = 'F_3' THEN nom END) + N', ' + MAX(CASE WHEN code = 'F_4' THEN nom END) + N' et '
                                           + MAX(CASE WHEN code = 'F_6' THEN nom END) FROM dbo.annexe_w_nom WHERE calcul_id = @c AND article = @art);
    DECLARE @s_r6 NVARCHAR (MAX) = @residu + N' nul, réparti sur les lignes ' + @noms,
            @m_r6 NVARCHAR (MAX) = @residu + N' à répartir entre les lignes ' + @noms + N', qu’aucun compte du plan ne porte (p. 111)';
    DECLARE @e DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'R_TVI', 1), @n INT, @s DECIMAL (38, 12), @r DECIMAL (38, 12);
    SELECT @n = COUNT(dbo.fn_ann_val(@c, @a, @art, value, 1)), @s = SUM(dbo.fn_ann_val(@c, @a, @art, value, 1)) FROM STRING_SPLIT('F_1,F_2,F_5', ',');
    SET @r = CASE WHEN @e IS NULL OR @n < 3 THEN NULL ELSE @e - @s END;
    DECLARE @code VARCHAR (24);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM (VALUES (1, 'F_3'), (2, 'F_4'), (3, 'F_6')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @r = 0
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = 'CALCULE', @valeur = 0,
                 @source = @s_r6, @regle = 'RR';
        ELSE
        BEGIN
            DECLARE @rg VARCHAR (12) = CASE WHEN @code = 'F_6' THEN 'A335_10' ELSE 'RR' END;
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1,
                 @motif = @m_r6, @regle = @rg;
        END;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur;
    IF @r IS NOT NULL AND @r <> 0
        EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = N'F_3;F_4;F_6', @col = 1, @parent = @r, @nom = @residu;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    EXEC dbo.pr_ann_totaux_formule @c = @c, @a = @a, @art = @art, @codes = 'TOTAL', @cols = '1,2';
    DECLARE @lp NVARCHAR (500) = N'Pourcentage de l''actif net moyen représenté par les frais de fonctionnement et de gestion';
    DECLARE @mt DECIMAL (38, 12);
    SELECT TOP (1) @mt = montant FROM dbo.saisie_annexe WHERE entite = @entite AND arrete = @a AND article = @art AND ligne = N'PCT_ACTIF_NET_MOYEN'
        AND LTRIM(RTRIM(colonne)) = N'1' ORDER BY id DESC;
    IF @mt IS NOT NULL
    BEGIN
        DECLARE @pct DECIMAL (38, 12) = @mt / 100;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'PCT_ACTIF_NET_MOYEN', @col = 1, @etat = 'SAISI', @valeur = @pct, @fmt = 'pct',
             @saisie_id = 0, @source = N'saisie du cabinet, en points de pourcentage', @libelle = @lp, @ordre = 8, @regle = 'NEUVE';
    END;
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'PCT_ACTIF_NET_MOYEN', @col = 1,
             @motif = N'actif net moyen de l’exercice absent de la base (une valeur liquidative par arrêté)', @fmt = 'pct', @saisie_id = 0,
             @libelle = @lp, @ordre = 8, @regle = 'NEUVE';
    DECLARE @lf NVARCHAR (500) = N'Frais de fonctionnement externes détaillés par nature';
    IF dbo.fn_ann_connue(@c, @a, @art, N'F_2', 1) = 1 AND dbo.fn_ann_val(@c, @a, @art, N'F_2', 1) = 0
        EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = N'FRAIS_EXTERNES_NATURE', @col = 1, @source = N'frais de fonctionnement externes nuls',
             @obligation = 'CONDITIONNELLE', @regle = 'NEUVE', @ordre = 9, @libelle = @lf;
    ELSE
    BEGIN
        DECLARE @ob VARCHAR (14) = CASE WHEN dbo.fn_ann_connue(@c, @a, @art, N'F_2', 1) = 1 THEN 'IMPOSEE' ELSE 'CONDITIONNELLE' END;
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'FRAIS_EXTERNES_NATURE', @col = 1, @motif = N'détail par nature absent de la base',
             @nature = 'texte', @obligation = @ob, @fmt = 'texte', @regle = 'NEUVE', @ordre = 9, @libelle = @lf;
    END;
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'SURPERFORMANCE', @col = 1, @termes = N'1|335-10|F_6|1', @formule = N'F_6[1]',
         @libelle = N'Montant des commissions de surperformance de l''exercice', @ordre = 10, @regle = 'NEUVE';
    DECLARE @col TINYINT = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', @col), @ee DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'R_TVI', @col);
        IF @v IS NOT NULL AND @ee IS NOT NULL
        BEGIN
            DECLARE @x DECIMAL (38, 12) = @v - @ee, @cle NVARCHAR (40) = N'colonne ' + CAST(@col AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_10_RESULTAT', @cle = @cle, @ecart = @x;
        END;
        SET @col += 1;
    END;
END;

GO

