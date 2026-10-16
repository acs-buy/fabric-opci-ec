
CREATE   PROCEDURE dbo.pr_ann_a_334_3 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '334-3', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @P VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @m NVARCHAR (400), @col TINYINT, @code VARCHAR (24);
    IF dbo.fn_ann_balance(@c, @a) = 0
    BEGIN
        EXEC dbo.pr_ann_cb_a_saisir @c = @c, @a = @a, @motif = N'arrêté sans balance';
        RETURN;
    END;
    DECLARE @s243 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '243', '', N'*', 0), @s245 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '245', '', N'*', 0),
            @s274 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '274', '', N'*', 0);
    DECLARE @actifs TABLE (code VARCHAR (40), cle NVARCHAR (1600));
    INSERT INTO @actifs SELECT code, dbo.fn_ann_cle_naturelle(code) FROM dbo.actif WHERE entite_detentrice = @entite AND nature = 'DROIT_CREDIT_BAIL';
    DECLARE @nb INT = (SELECT COUNT(*) FROM @actifs);
    DECLARE @cb BIT = CASE WHEN @s243 <> 0 OR @s245 <> 0 OR @s274 <> 0 OR @nb > 0 THEN 1 ELSE 0 END;
    IF @cb = 0
    BEGIN
        IF @P IS NULL OR dbo.fn_ann_balance(@c, @P) = 0
        BEGIN
            SET @m = N'arrêté N-1 (' + dbo.fn_ann_arrete_fr(@c, @P) + N') sans balance';
            EXEC dbo.pr_ann_cb_a_saisir @c = @c, @a = @a, @motif = @m;
            RETURN;
        END;
        SET @cb = CASE WHEN dbo.fn_ann_S(@c, @P, '243', '', N'*', 0) <> 0 OR dbo.fn_ann_S(@c, @P, '245', '', N'*', 0) <> 0
                            OR dbo.fn_ann_S(@c, @P, '274', '', N'*', 0) <> 0 THEN 1 ELSE 0 END;
    END;
    DECLARE @cols TABLE (n INT, col TINYINT);
    INSERT INTO @cols VALUES (1, 3), (2, 2), (3, 4), (4, 5), (5, 6), (6, 1);
    DECLARE @infos TABLE (n INT, code VARCHAR (24));
    INSERT INTO @infos VALUES (1, 'ASSIETTE'), (2, 'REDEVANCES_N'), (3, 'REDEVANCES_CUM'), (4, 'RESTANT_1AN'), (5, 'RESTANT_1_5ANS'), (6, 'RESTANT_5ANS');
    DECLARE @src NVARCHAR (MAX), @v DECIMAL (38, 12);
    IF @cb = 0
    BEGIN
        DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT col FROM @cols ORDER BY n;
        OPEN cur; FETCH NEXT FROM cur INTO @col;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'CB:NEANT', @col = @col, @motif = N'aucun contrat de crédit-bail',
                 @libelle = N'Néant', @ordre = 7.5, @regle = 'NEANT';
            FETCH NEXT FROM cur INTO @col;
        END;
        CLOSE cur; DEALLOCATE cur;
        SET @v = @s243 + @s274;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = 1, @etat = 'LU', @valeur = @v, @source = N'soldes des 243 et 274',
             @obligation = 'SANS', @nature = 'calcul', @regle = 'RL';
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL';
        SET @src = N'aucun contrat de crédit-bail : comptes 243, 245 et 274 nuls aux 2 clôtures, aucun droit de crédit-bail au registre des actifs ; total d’un tableau sans ligne';
        SET @col = 3;
        WHILE @col <= 6
        BEGIN
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @etat = 'CALCULE', @valeur = 0, @source = @src,
                 @regle = 'A334_3', @nature = 'calcul', @obligation = 'SANS';
            SET @col += 1;
        END;
        DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM @infos ORDER BY n;
        OPEN cur2; FETCH NEXT FROM cur2 INTO @code;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = 'CALCULE', @valeur = 0, @source = @src, @regle = 'A334_3';
            FETCH NEXT FROM cur2 INTO @code;
        END;
        CLOSE cur2; DEALLOCATE cur2;
        EXEC dbo.pr_ann_prix_residuel @c = @c, @a = @a, @mode = 'ZERO', @source = @src;
    END;
    ELSE
    BEGIN
        DECLARE @lignes TABLE (n INT IDENTITY, l NVARCHAR (120));
        DECLARE @ac VARCHAR (40), @l NVARCHAR (120);
        DECLARE cur3 CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM @actifs ORDER BY cle COLLATE Latin1_General_100_BIN2;
        OPEN cur3; FETCH NEXT FROM cur3 INTO @ac;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @l = N'CB:' + @ac;
            INSERT INTO @lignes (l) VALUES (@l);
            DECLARE @lib NVARCHAR (500) = @ac;
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @motif = N'assiette du contrat, absente de la base', @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            IF @nb = 1
            BEGIN
                SET @v = @s243 + @s274;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @valeur = @v,
                     @source = N'comptes 243 et 274, un seul contrat de crédit-bail les portant', @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            END;
            ELSE
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = N'plusieurs contrats : 243 et 274 non ventilés par contrat',
                     @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @l, @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            EXEC dbo.pr_ann_regle_m @c = @c, @a = @a, @art = @art, @ligne = @l, @col_aug = 4, @col_dim = 5, @comptes = '243', @exclues = '',
                 @code_filtre = @ac, @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            DECLARE @p274 DECIMAL (38, 12) = CASE WHEN @P IS NOT NULL THEN dbo.fn_ann_S(@c, @P, '274', '', N'*', 0) END;
            IF @nb = 1 AND @p274 IS NOT NULL
            BEGIN
                SET @v = @s274 - @p274;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @etat = 'CALCULE', @valeur = @v,
                     @source = N'compte 274, N moins N-1, un seul contrat de crédit-bail le portant', @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            END;
            ELSE
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @motif = N'variation du 274 non attribuable au contrat',
                     @libelle = @lib, @ordre = 7.5, @regle = 'RC7';
            FETCH NEXT FROM cur3 INTO @ac;
        END;
        CLOSE cur3; DEALLOCATE cur3;
        IF @nb = 0
        BEGIN
            INSERT INTO @lignes (l) VALUES (N'CB:SAISIE');
            DECLARE cur4 CURSOR LOCAL FAST_FORWARD FOR SELECT col FROM @cols ORDER BY n;
            OPEN cur4; FETCH NEXT FROM cur4 INTO @col;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'CB:SAISIE', @col = @col,
                     @motif = N'crédit-bail au bilan sans droit de crédit-bail au registre des actifs', @libelle = N'Contrat de crédit-bail à inventorier', @ordre = 7.5, @regle = 'A334_3';
                FETCH NEXT FROM cur4 INTO @col;
            END;
            CLOSE cur4; DEALLOCATE cur4;
        END;
        DECLARE cur5 CURSOR LOCAL FAST_FORWARD FOR SELECT col FROM @cols ORDER BY n;
        OPEN cur5; FETCH NEXT FROM cur5 INTO @col;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @t NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|334-3|' + l + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @lignes);
            EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @termes = @t;
            FETCH NEXT FROM cur5 INTO @col;
        END;
        CLOSE cur5; DEALLOCATE cur5;
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'ASSIETTE', @col = 1, @termes = N'1|334-3|TOTAL|3';
        DECLARE cur6 CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM @infos WHERE n > 1 ORDER BY n;
        OPEN cur6; FETCH NEXT FROM cur6 INTO @code;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'information du contrat, absente de la base', @regle = 'A334_3';
            FETCH NEXT FROM cur6 INTO @code;
        END;
        CLOSE cur6; DEALLOCATE cur6;
        EXEC dbo.pr_ann_prix_residuel @c = @c, @a = @a, @mode = 'AR', @motif = N'information du contrat, absente de la base';
    END;
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @tv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', @col), @b DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_2', @col);
        IF @tv IS NOT NULL AND @b IS NOT NULL
        BEGIN
            DECLARE @e DECIMAL (38, 12) = @tv - @b, @cle NVARCHAR (40) = N'334-3 colonne ' + CAST(@col AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_BILAN', @cle = @cle, @ecart = @e;
        END;
        SET @col += 1;
    END;
END;

GO

