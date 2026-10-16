
CREATE   PROCEDURE dbo.pr_ann_a_333_3 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n_cp1 NVARCHAR (MAX) = N'bilan, ligne ' + dbo.fn_ann_nom_etat('P_CP') + N', exercice N-1',
            @n_cp NVARCHAR (MAX) = N'bilan, ligne ' + dbo.fn_ann_nom_etat('P_CP') + N', exercice N',
            @n_rn NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat('R_RN'),
            @n_rpmv NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat('R_RPMV');
    DECLARE @art VARCHAR (10) = '333-3', @v DECIMAL (38, 12), @sg VARCHAR (4), @code VARCHAR (24), @col TINYINT, @src NVARCHAR (MAX);
    DECLARE @flux NVARCHAR (200) = N'solde de clôture lu comme flux de l’exercice';
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    -- colonne 1
    SET @v = dbo.fn_ann_E(@c, @a, 'P_CP', 2); SET @sg = dbo.fn_ann_signe_333_3('AN_DEBUT');
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'AN_DEBUT', @col = 1, @v = @v,
         @source = @n_cp1, @nature = 'etat', @regle = 'RC10';
    UPDATE dbo.annexe_w_cel SET signe = @sg WHERE calcul_id = @c AND arrete = @a AND article = @art AND ligne = N'AN_DEBUT' AND colonne = 1;
    SET @sg = dbo.fn_ann_signe_333_3('SOUSCRIPTIONS');
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'SOUSCRIPTIONS', @col = 1,
         @termes = N'1|333-2|SOUSCRIPTIONS|1;1|333-2|SOUSCRIPTIONS|4', @regle = 'A333_3', @signe = @sg;
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'RACHATS', @col = 1,
         @termes = N'1|333-2|RACHATS|1;-1|333-2|RACHATS|4', @regle = 'A333_3';
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM (VALUES (1, 'FRAIS_ACQ'), (2, 'RESULTAT'), (3, 'ACOMPTES')) x (n, code) ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sg = dbo.fn_ann_signe_333_3(@code);
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'rubrique', @regle = 'RC1', @signe = @sg;
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2, @motif = N'rubrique', @regle = 'RC1', @signe = @sg;
        FETCH NEXT FROM cur INTO @code;
    END;
    CLOSE cur; DEALLOCATE cur;
    -- frais (IR5) : 1041 et 1049 par actif, hors lots d'affectation
    DECLARE @fn DECIMAL (38, 12), @fr DECIMAL (38, 12), @fsrc NVARCHAR (200);
    IF dbo.fn_ann_balance(@c, @a) = 0
        SELECT @fn = NULL, @fr = NULL, @fsrc = N'arrêté sans balance';
    ELSE
    BEGIN
        DECLARE @nlignes INT, @sans_axe INT;
        SELECT @nlignes = COUNT(*), @sans_axe = SUM(CASE WHEN code_actif IS NULL THEN 1 ELSE 0 END)
        FROM dbo.annexe_w_axe WHERE calcul_id = @c AND arrete = @a AND (compte_num LIKE '1041%' OR compte_num LIKE '1049%') AND aff = 0;
        IF @nlignes = 0 OR @sans_axe > 0
        BEGIN
            IF dbo.fn_ann_S(@c, @a, '1041', '', N'*', 1) = 0 AND dbo.fn_ann_S(@c, @a, '1049', '', N'*', 1) = 0
                SELECT @fn = 0, @fr = 0, @fsrc = N'1041 et 1049 nuls, hors lots d’affectation';
            ELSE
                SELECT @fn = NULL, @fr = NULL, @fsrc = N'écriture du 1041 ou du 1049 non ventilée par actif';
        END;
        ELSE
        BEGIN
            SELECT @fn = ISNULL(SUM(CASE WHEN s > 0 THEN s END), 0), @fr = ISNULL(SUM(CASE WHEN s < 0 THEN s END), 0)
            FROM (SELECT code_actif, SUM(solde) AS s FROM dbo.annexe_w_axe
                  WHERE calcul_id = @c AND arrete = @a AND (compte_num LIKE '1041%' OR compte_num LIKE '1049%') AND aff = 0
                  GROUP BY code_actif) p;
            SET @fsrc = N'1041 et 1049 ventilés par actif (comptabilité analytique)';
        END;
    END;
    DECLARE @i INT = 1;
    WHILE @i <= 2
    BEGIN
        SELECT @code = CASE @i WHEN 1 THEN 'FRAIS_ACQ_N' ELSE 'FRAIS_ACQ_RES' END, @v = CASE @i WHEN 1 THEN @fn ELSE @fr END;
        IF @v IS NULL
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = @fsrc, @regle = 'A333_3';
        ELSE
        BEGIN
            DECLARE @et VARCHAR (12) = CASE WHEN @fsrc LIKE N'%nuls%' THEN 'LU' ELSE 'CALCULE' END;
            SET @src = @fsrc + N' ; ' + @flux;
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = @et, @valeur = @v, @source = @src, @regle = 'A333_3';
        END;
        SET @i += 1;
    END;
    DECLARE @s106 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '106', '', N'*', 1);
    SET @sg = dbo.fn_ann_signe_333_3('CHANGE');
    IF @s106 IS NULL
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'CHANGE', @col = 1, @motif = N'arrêté sans balance', @regle = 'A333_3', @signe = @sg;
    ELSE
    BEGIN
        SET @v = -@s106; SET @src = N'solde créditeur du 106, hors lots d’affectation ; ' + @flux;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'CHANGE', @col = 1, @etat = 'LU', @valeur = @v, @source = @src, @regle = 'A333_3', @signe = @sg;
    END;
    -- differences d'estimation : stocks des 27, 294, 295, 296 (classe 2) et du 37 (classe 3)
    SET @i = 1;
    WHILE @i <= 2
    BEGIN
        SET @code = CASE @i WHEN 1 THEN 'DE_IMMO_N' ELSE 'DE_FIN_N' END;
        IF dbo.fn_ann_balance(@c, @a) = 0
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'arrêté sans balance', @regle = 'A333_3';
        ELSE
        BEGIN
            IF @i = 2 SELECT @v = dbo.fn_ann_S(@c, @a, '37', '', N'*', 0), @src = N'solde débiteur du 37';
            ELSE SELECT @v = dbo.fn_ann_S(@c, @a, '27', '', N'*', 0) + dbo.fn_ann_S(@c, @a, '294', '', N'*', 0) + dbo.fn_ann_S(@c, @a, '295', '', N'*', 0)
                             + dbo.fn_ann_S(@c, @a, '296', '', N'*', 0),
                        @src = N'solde débiteur des 27, 294, 295 et 296 (article 223-2, p. 88)';
            IF @v IS NULL
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = @src, @regle = 'A333_3';
            ELSE
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = 'LU', @valeur = @v, @source = @src, @regle = 'A333_3';
        END;
        SET @i += 1;
    END;
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'DE_IMMO_N1', @col = 1, @de_art = '333-3', @de_ligne = N'DE_IMMO_N', @de_col = 1;
    EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = N'DE_FIN_N1', @col = 1, @de_art = '333-3', @de_ligne = N'DE_FIN_N', @de_col = 1;
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR SELECT code FROM (VALUES (1, 'DE_IMMO_N'), (2, 'DE_IMMO_N1'), (3, 'DE_FIN_N'), (4, 'DE_FIN_N1')) x (n, code) ORDER BY n;
    OPEN cur2; FETCH NEXT FROM cur2 INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 2,
             @motif = N'le modèle porte une seule valeur, dans le cadre accolé au libellé (p. 99)', @regle = 'RC1';
        FETCH NEXT FROM cur2 INTO @code;
    END;
    CLOSE cur2; DEALLOCATE cur2;
    EXEC dbo.pr_ann_distrib_prec @c = @c, @a = @a;
    SET @v = dbo.fn_ann_E(@c, @a, 'R_RN', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'RES_NET', @col = 1, @v = @v, @source = @n_rn, @nature = 'etat';
    SET @v = dbo.fn_ann_E(@c, @a, 'R_RPMV', 1);
    EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = N'RES_PMV', @col = 1, @v = @v, @source = @n_rpmv, @nature = 'etat';
    DECLARE @s1081 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '1081', '', N'*', 1);
    SET @sg = dbo.fn_ann_signe_333_3('FUSION');
    IF @s1081 IS NULL
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'FUSION', @col = 1, @motif = N'arrêté sans balance', @regle = 'A333_3', @signe = @sg;
    ELSE
    BEGIN
        SET @v = -@s1081; SET @src = N'solde créditeur du 1081, hors lots d’affectation ; ' + @flux;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'FUSION', @col = 1, @etat = 'LU', @valeur = @v, @source = @src, @regle = 'A333_3', @signe = @sg;
    END;
    DECLARE @s107 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '107', '', N'*', 1);
    SET @v = CASE WHEN @s107 IS NULL THEN NULL ELSE -(@s107 + dbo.fn_ann_S(@c, @a, '108', '1081', N'*', 1) + dbo.fn_ann_S(@c, @a, '109', '', N'*', 1)) END;
    IF @v IS NULL
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'AUTRES', @col = 1, @motif = N'arrêté sans balance', @regle = 'A333_3';
    ELSE
    BEGIN
        SET @src = N'solde créditeur des 107, 108 hors 1081, 109, hors lots d’affectation ; ' + @flux;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'AUTRES', @col = 1, @etat = 'LU', @valeur = @v, @source = @src, @regle = 'A333_3';
    END;
    -- variations, colonne N ; acomptes repris du 333-1 (H3)
    SET @sg = dbo.fn_ann_signe_333_3('VAR_DE_IMMO');
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'VAR_DE_IMMO', @col = 1, @termes = N'1|333-3|DE_IMMO_N|1;-1|333-3|DE_IMMO_N1|1', @signe = @sg;
    SET @sg = dbo.fn_ann_signe_333_3('VAR_DE_FIN');
    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'VAR_DE_FIN', @col = 1, @termes = N'1|333-3|DE_FIN_N|1;-1|333-3|DE_FIN_N1|1', @signe = @sg;
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @ta NVARCHAR (100) = N'-1|333-1|SD_AC_NET|' + CAST(@col AS NVARCHAR (2)), @tb NVARCHAR (100) = N'-1|333-1|SD_AC_PMV|' + CAST(@col AS NVARCHAR (2));
        SET @sg = dbo.fn_ann_signe_333_3('AC_RES_NET');
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'AC_RES_NET', @col = @col, @termes = @ta, @regle = 'H3', @signe = @sg;
        SET @sg = dbo.fn_ann_signe_333_3('AC_CESSIONS');
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'AC_CESSIONS', @col = @col, @termes = @tb, @regle = 'H3', @signe = @sg;
        SET @col += 1;
    END;
    -- colonne 2 : regle N
    DECLARE @nat VARCHAR (8), @en1 VARCHAR (40);
    DECLARE cur3 CURSOR LOCAL FAST_FORWARD FOR
        SELECT code FROM (VALUES (1, 'AN_DEBUT'), (2, 'SOUSCRIPTIONS'), (3, 'RACHATS'), (4, 'FRAIS_ACQ_N'), (5, 'FRAIS_ACQ_RES'), (6, 'CHANGE'),
            (7, 'VAR_DE_IMMO'), (8, 'VAR_DE_FIN'), (9, 'DISTRIB_PREC'), (10, 'RES_NET'), (11, 'RES_PMV'), (12, 'FUSION'), (13, 'AUTRES')) x (n, code) ORDER BY n;
    OPEN cur3; FETCH NEXT FROM cur3 INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @nat = CASE WHEN @code IN ('AN_DEBUT', 'RES_NET', 'RES_PMV') THEN 'etat' ELSE 'source' END,
               @en1 = CASE @code WHEN 'RES_NET' THEN 'R_RN' WHEN 'RES_PMV' THEN 'R_RPMV' END,
               @sg = dbo.fn_ann_signe_333_3(@code);
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code, @nature = @nat, @etat_n1 = @en1, @signe = @sg;
        FETCH NEXT FROM cur3 INTO @code;
    END;
    CLOSE cur3; DEALLOCATE cur3;
    -- RENVOI_1 : due quand la distribution precedente ou les autres elements ne sont pas nuls
    IF dbo.fn_ann_connue(@c, @a, @art, N'DISTRIB_PREC', 1) = 1 AND dbo.fn_ann_connue(@c, @a, @art, N'AUTRES', 1) = 1
       AND dbo.fn_ann_val(@c, @a, @art, N'DISTRIB_PREC', 1) = 0 AND dbo.fn_ann_val(@c, @a, @art, N'AUTRES', 1) = 0
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'RENVOI_1', @col = 1, @motif = N'distribution précédente et autres éléments nuls',
             @regle = 'NEUVE', @libelle = N'Explication du renvoi 1 (p. 99)', @ordre = 24, @fmt = 'texte';
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'RENVOI_1', @col = 1, @motif = N'renvoi 1 : explication précise due par l’OPCI',
             @nature = 'texte', @regle = 'NEUVE', @libelle = N'Explication du renvoi 1 (p. 99)', @ordre = 24, @fmt = 'texte';
    -- AN_FIN : l'actif net du bilan
    SET @sg = '=';
    SET @v = dbo.fn_ann_E(@c, @a, 'P_CP', 1);
    IF @v IS NULL
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'AN_FIN', @col = 1, @motif = N'bilan absent', @nature = 'etat', @regle = 'RC10', @signe = @sg;
    ELSE
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'AN_FIN', @col = 1, @etat = 'LU', @valeur = @v,
             @source = @n_cp, @nature = 'etat', @regle = 'RC10', @signe = @sg;
    IF dbo.fn_ann_connue(@c, @n1, @art, N'AN_FIN', 1) = 1
    BEGIN
        SET @v = dbo.fn_ann_val(@c, @n1, @art, N'AN_FIN', 1);
        SET @src = N'annexe de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @n1) + N', ' + dbo.fn_ann_nom_ligne(@c, @n1, @art, N'AN_FIN') + N', colonne 1';
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'AN_FIN', @col = 2, @etat = 'LU', @valeur = @v,
             @source = @src, @nature = 'etat', @regle = 'RN', @signe = @sg;
    END;
    ELSE
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'AN_FIN', @col = 2, @termes = N'1|333-3|AN_DEBUT|1',
             @formule = N'+ 333-3 AN_DEBUT[1]', @regle = 'RC10', @signe = @sg;
    -- controle C333_3_AN : la somme algebrique des lignes egale l'actif net de fin
    SET @col = 1;
    WHILE @col <= 2
    BEGIN
        DECLARE @termes NVARCHAR (MAX) = dbo.fn_ann_termes_formule(@art, 'AN_FIN', @col);
        DECLARE @fin DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'AN_FIN', @col), @nt INT, @nc INT, @sv DECIMAL (38, 12);
        SELECT @nt = COUNT(*), @nc = COUNT(w.v), @sv = SUM(t.sg * w.v)
        FROM (SELECT CAST(PARSENAME(REPLACE(x.value, N'|', N'.'), 4) AS INT) AS sg, PARSENAME(REPLACE(x.value, N'|', N'.'), 2) AS lig,
                     CAST(PARSENAME(REPLACE(x.value, N'|', N'.'), 1) AS TINYINT) AS col
              FROM STRING_SPLIT(@termes, N';') x WHERE x.value <> N'') t
        CROSS APPLY (SELECT dbo.fn_ann_val(@c, @a, @art, t.lig, t.col) AS v) w;
        IF @fin IS NOT NULL AND @nt = @nc
        BEGIN
            DECLARE @e DECIMAL (38, 12) = ISNULL(@sv, 0) - @fin, @cle NVARCHAR (40) = N'colonne ' + CAST(@col AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C333_3_AN', @cle = @cle, @ecart = @e;
        END;
        SET @col += 1;
    END;
    -- signal : reports N = reports et resultat de N-1 moins la distribution de l'exercice precedent
    IF @n1 IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @n1 AND mission = 1)
    BEGIN
        DECLARE @rn2 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'P_CP_2', 1), @rn3 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'P_CP_3', 1),
                @rp2 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @n1, 'P_CP_2', 1), @rp3 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @n1, 'P_CP_3', 1),
                @rp4 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @n1, 'P_CP_4', 1), @rp5 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @n1, 'P_CP_5', 1),
                @dpv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'DISTRIB_PREC', 1);
        IF @dpv IS NOT NULL AND @rn2 IS NOT NULL AND @rn3 IS NOT NULL AND @rp2 IS NOT NULL AND @rp3 IS NOT NULL AND @rp4 IS NOT NULL AND @rp5 IS NOT NULL
        BEGIN
            DECLARE @er DECIMAL (38, 12) = (@rn2 + @rn3) - ((@rp2 + @rp3 + @rp4 + @rp5) - @dpv);
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S333_3_REPORTS', @cle = N'colonne 1', @ecart = @er;
        END;
    END;
END;

GO

