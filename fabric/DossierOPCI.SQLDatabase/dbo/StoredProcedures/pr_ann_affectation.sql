
-- ------------------------------------------------------------------------------------------------- 335-12, affectation
CREATE   PROCEDURE dbo.pr_ann_affectation @c INT, @a VARCHAR (20), @section VARCHAR (2), @col TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-12', @parent VARCHAR (24) = @section + '_D_T';
    DECLARE @c1 VARCHAR (24) = @section + '_A_1', @c2 VARCHAR (24) = @section + '_A_2', @c3 VARCHAR (24) = @section + '_A_3';
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @pv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @parent, @col);
    DECLARE @att TABLE (n INT, art VARCHAR (10), ligne VARCHAR (24), col TINYINT);
    IF dbo.fn_ann_etat(@c, @a, @art, @parent, @col) = 'EN_ATTENTE' INSERT INTO @att VALUES (1, @art, @parent, @col);
    DECLARE @faites TABLE (code VARCHAR (24));
    DECLARE @dec DECIMAL (38, 12) = dbo.fn_ann_decision(@c, @a, @col, @section), @src NVARCHAR (MAX), @m NVARCHAR (MAX);
    IF @dec IS NOT NULL
    BEGIN
        SET @src = N'décision de distribution enregistrée au dossier : ' + CASE WHEN @section = 'I' THEN N'distribution décidée sur le résultat distribuable afférent aux produits, produits de sociétés exonérées compris' ELSE N'distribution décidée sur les plus-values de cession' END;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @c1, @col = @col, @etat = 'LU', @valeur = @dec, @source = @src, @regle = 'A335_12';
        INSERT INTO @faites VALUES (@c1);
    END;
    IF @col = 2 AND @section = 'I'
    BEGIN
        DECLARE @ii_etat VARCHAR (12) = dbo.fn_ann_etat(@c, @a, @art, N'II_D_T', 2), @ii DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'II_D_T', 2);
        DECLARE @dp_connue BIT = dbo.fn_ann_connue(@c, @a, '333-3', N'DISTRIB_PREC', 1), @dp DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, '333-3', N'DISTRIB_PREC', 1);
        IF NOT EXISTS (SELECT 1 FROM @faites WHERE code = @c1) AND @ii = 0 AND @dp_connue = 1
        BEGIN
            DECLARE @prev VARCHAR (20) = dbo.fn_ann_annuel_precedent(@c, @a);
            SET @m = CASE WHEN @prev IS NULL THEN N'clôture annuelle qui précède l’arrêté absente du dossier' ELSE dbo.fn_ann_distrib_prec_motif(@c, @dp, @prev, @a) END;
            IF @m IS NULL
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @c1, @col = 2, @etat = 'CALCULE', @valeur = @dp, @nature = 'calcul', @obligation = 'SANS',
                     @ops = N'333-3|DISTRIB_PREC|1;335-12|II_D_T|2', @formule = N'+ 333-3 DISTRIB_PREC[1]',
                     @source = N'333-3, distribution de l’exercice précédent (colonne Exercice N), rapprochée du registre des porteurs ; rien de distribuable sur les plus-values',
                     @regle = 'A335_12';
            ELSE
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @c1, @col = 2, @motif = @m, @regle = 'A335_12';
            INSERT INTO @faites VALUES (@c1);
        END;
        ELSE IF NOT EXISTS (SELECT 1 FROM @faites WHERE code = @c1) AND @ii_etat = 'EN_ATTENTE' AND @dp_connue = 1
            INSERT INTO @att VALUES (2, @art, 'II_D_T', 2);
        DECLARE @s111 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '111', '', N'*', 0);
        IF EXISTS (SELECT 1 FROM @faites WHERE code = @c1) AND @s111 IS NOT NULL
        BEGIN
            DECLARE @v111 DECIMAL (38, 12) = -@s111;
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @c2, @col = 2, @etat = 'LU', @valeur = @v111, @regle = 'A335_12',
                 @source = N'solde créditeur du 111 à l’arrêté N : report à nouveau issu de l’affectation de l’exercice N-1 (article 411-2, p. 108)';
            INSERT INTO @faites VALUES (@c2);
        END;
    END;
    DECLARE @lue_a_n BIT = CASE WHEN @col = 2 AND EXISTS (SELECT 1 FROM @faites WHERE code = @c1) THEN 1 ELSE 0 END;
    DECLARE @code VARCHAR (24), @k INT = 1;
    DECLARE @ops NVARCHAR (MAX) = (SELECT STRING_AGG(art + N'|' + ligne + N'|' + CAST(col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @att);
    WHILE @k <= 3
    BEGIN
        SET @code = CASE @k WHEN 1 THEN @c1 WHEN 2 THEN @c2 ELSE @c3 END;
        IF NOT EXISTS (SELECT 1 FROM @faites WHERE code = @code)
        BEGIN
            DECLARE @pe VARCHAR (12) = dbo.fn_ann_etat(@c, @n1, @art, @code, 1);
            DECLARE @recopie BIT = CASE WHEN @col = 2 AND @lue_a_n = 0 AND @pe IN ('LU', 'CALCULE', 'SAISI', 'SANS_OBJET') THEN 1 ELSE 0 END;
            IF @pv = 0
            BEGIN
                SET @src = dbo.fn_ann_designer(@c, @a, @art, @parent, @col) + N', nulle : chaque composante est nulle';
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @etat = 'CALCULE', @valeur = 0, @source = @src, @regle = 'RP';
            END;
            ELSE IF EXISTS (SELECT 1 FROM @att) AND @recopie = 0
            BEGIN
                DECLARE @f NVARCHAR (MAX) = N'règle P, distribution de l’exercice précédent, report du 111 ou règle U sur '
                    + (SELECT STRING_AGG(ligne + N'[' + CAST(col AS NVARCHAR (2)) + N']', N', ') WITHIN GROUP (ORDER BY n) FROM @att);
                DECLARE @mo NVARCHAR (MAX) = N'sommes distribuables en attente ('
                    + (SELECT STRING_AGG(dbo.fn_ann_designer(@c, @a, art, ligne, col), N' ; ') WITHIN GROUP (ORDER BY n) FROM @att)
                    + N') : la composante s’en déduit dès qu’elles sont établies';
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @etat = 'EN_ATTENTE', @nature = 'calcul', @obligation = 'SANS',
                     @ops = @ops, @regle = 'RC4', @formule = @f, @motif = @mo;
            END;
            ELSE IF @lue_a_n = 1
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'affectation de l’exercice N-1 : composante non lue à N', @regle = 'A335_12';
            ELSE IF @col = 2
                EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @code;
            ELSE
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @col, @motif = N'affectation proposée, absente de la base', @regle = 'RP';
        END;
        SET @k += 1;
    END;
    DECLARE @cs NVARCHAR (100) = @c1 + N';' + @c2 + N';' + @c3;
    DECLARE @nom_par NVARCHAR (MAX) = dbo.fn_ann_designer(@c, @a, @art, @parent, @col);
    EXEC dbo.pr_ann_regle_u @c = @c, @a = @a, @art = @art, @codes = @cs, @col = @col, @parent = @pv, @nom = @nom_par;
END;

GO

