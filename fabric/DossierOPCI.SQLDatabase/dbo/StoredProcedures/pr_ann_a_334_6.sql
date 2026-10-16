
-- ------------------------------------------------------------------------------------------------- 334-6
CREATE   PROCEDURE dbo.pr_ann_a_334_6 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '334-6', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @P VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @dn DATE = dbo.fn_ann_date(@c, @a);
    DECLARE @sans_registre NVARCHAR (400) = N'avances et remboursements de compte courant : la base ne les enregistre pas, le registre des mouvements d’actifs ne portant que des acquisitions, des travaux, des cessions et des sorties ; la base n’établit que la variation nette du 266 de l’emprunteur, %s';
    DECLARE @contrats TABLE (n INT IDENTITY, reference NVARCHAR (60), emp VARCHAR (20), denomination NVARCHAR (400), capital DECIMAL (38, 12), echeance DATE);
    INSERT INTO @contrats (reference, emp, denomination, capital, echeance)
    SELECT e.reference, e.entite_emprunt, f.denomination, e.capital_restant, e.date_echeance
    FROM dbo.emprunt_intragroupe e LEFT JOIN dbo.ref_entite f ON f.code = e.entite_emprunt
    WHERE e.entite_preteuse = @entite AND (e.date_versement IS NULL OR CAST(e.date_versement AS DATE) <= @dn)
    ORDER BY dbo.fn_ann_cle_naturelle(e.reference) COLLATE Latin1_General_100_BIN2;
    DECLARE @codes TABLE (n INT IDENTITY, l NVARCHAR (120));
    DECLARE @i INT = 1, @nc INT = (SELECT COUNT(*) FROM @contrats);
    DECLARE @ref NVARCHAR (60), @emp VARCHAR (20), @den NVARCHAR (400), @cap DECIMAL (38, 12), @ech DATE, @l NVARCHAR (120), @lib NVARCHAR (500);
    DECLARE @s266 DECIMAL (38, 12), @s276 DECIMAL (38, 12), @v DECIMAL (38, 12), @src NVARCHAR (MAX), @m NVARCHAR (MAX);
    WHILE @i <= @nc
    BEGIN
        SELECT @ref = reference, @emp = emp, @den = denomination, @cap = capital, @ech = echeance FROM @contrats WHERE n = @i;
        SET @l = N'CC:' + @ref;
        INSERT INTO @codes (l) VALUES (@l);
        SET @lib = @ref + N', ' + ISNULL(NULLIF(@den, N''), @emp);
        SET @s266 = dbo.fn_ann_S(@c, @a, '266', '', @emp, 0);
        SET @s276 = dbo.fn_ann_S(@c, @a, '276', '', @emp, 0);
        IF @s266 IS NULL
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = N'arrêté sans balance', @regle = 'RC8', @ordre = 1, @libelle = @lib;
        ELSE IF (SELECT COUNT(*) FROM @contrats WHERE emp = @emp) = 1
        BEGIN
            SET @v = @s266 + @s276; SET @src = N'266 et 276 au compte auxiliaire de ' + dbo.fn_ann_nom_entite(@emp);
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @valeur = @v, @source = @src, @regle = 'RC8', @ordre = 1, @libelle = @lib;
        END;
        ELSE
        BEGIN
            IF (SELECT ISNULL(SUM(ISNULL(capital, 0)), 0) FROM @contrats WHERE emp = @emp) = @s266 AND @s276 = 0
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'CALCULE', @valeur = @cap,
                     @source = N'capital restant du contrat', @regle = 'RC8', @ordre = 1, @libelle = @lib;
            ELSE
            BEGIN
                SET @m = N'plusieurs contrats pour ' + dbo.fn_ann_nom_entite(@emp) + N', non ventilés par la balance';
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = @m, @regle = 'RC8', @ordre = 1, @libelle = @lib;
            END;
        END;
        EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @l, @regle = 'RN', @ordre = 1, @libelle = @lib;
        DECLARE @cn DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '266', '', @emp, 0),
                @cp DECIMAL (38, 12) = CASE WHEN @P IS NOT NULL THEN dbo.fn_ann_S(@c, @P, '266', '', @emp, 0) END;
        EXEC dbo.pr_ann_regle_m @c = @c, @a = @a, @art = @art, @ligne = @l, @col_aug = 3, @col_dim = 4, @comptes = '266', @exclues = '',
             @registre = 0, @sans_registre = @sans_registre, @cout_impose = 1, @cout_n = @cn, @cout_p = @cp, @regle = 'RC8', @libelle = @lib, @ordre = 1;
        DECLARE @p276 DECIMAL (38, 12) = CASE WHEN @P IS NOT NULL THEN dbo.fn_ann_S(@c, @P, '276', '', @emp, 0) END;
        DECLARE @sans_aux BIT = CASE WHEN EXISTS (SELECT 1 FROM dbo.annexe_w_sol WHERE calcul_id = @c AND arrete = @a AND comp_aux_num IS NULL
                                                  AND compte_num LIKE '276%' AND solde <> 0) THEN 1 ELSE 0 END;
        IF @s276 IS NULL OR @p276 IS NULL OR @sans_aux = 1
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @motif = N'variation du 276 non attribuable au contrat', @regle = 'RC8', @ordre = 1, @libelle = @lib;
        ELSE
        BEGIN
            SET @v = @s276 - @p276; SET @src = N'276 au compte auxiliaire de ' + dbo.fn_ann_nom_entite(@emp) + N', N moins N-1';
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @etat = 'CALCULE', @valeur = @v, @source = @src, @regle = 'RC8', @ordre = 1, @libelle = @lib;
        END;
        IF @ech IS NOT NULL
        BEGIN
            DECLARE @tx NVARCHAR (40) = dbo.fn_ann_date_fr(CONVERT(NVARCHAR (10), @ech, 23));
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @etat = 'LU', @fmt = 'texte', @texte = @tx,
                 @source = N'échéance du contrat d’avance en compte courant', @obligation = 'CONDITIONNELLE', @regle = 'RC8', @ordre = 1, @libelle = @lib;
        END;
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @motif = N'échéance du contrat absente', @fmt = 'texte',
                 @obligation = 'CONDITIONNELLE', @regle = 'RC8', @ordre = 1, @libelle = @lib;
        SET @i += 1;
    END;
    IF @nc = 0
    BEGIN
        DECLARE @v1 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '266', '', N'*', 0);
        DECLARE @n1_inconnu BIT = CASE WHEN @P IS NULL OR dbo.fn_ann_balance(@c, @P) = 0 THEN 1 ELSE 0 END;
        DECLARE @col TINYINT;
        IF @v1 IS NULL OR (@v1 = 0 AND @n1_inconnu = 1)
        BEGIN
            SET @l = N'CC:SAISIE';
            SET @m = CASE WHEN @v1 IS NULL THEN N'arrêté sans balance' ELSE N'arrêté N-1 (' + dbo.fn_ann_arrete_fr(@c, @P) + N') sans balance' END;
            DECLARE @m2 NVARCHAR (MAX) = @m + N' : comptes courants de l’exercice non établis';
            SET @col = 1;
            WHILE @col <= 5
            BEGIN
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = @m2, @regle = 'RC8', @ordre = 1, @libelle = N'Compte courant à inventorier';
                SET @col += 1;
            END;
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @motif = @m, @fmt = 'texte', @obligation = 'CONDITIONNELLE', @regle = 'RC8', @ordre = 1, @libelle = N'Compte courant à inventorier';
            INSERT INTO @codes (l) VALUES (@l);
        END;
        ELSE IF @v1 <> 0
        BEGIN
            SET @l = N'COMPTES_COURANTS';
            SET @v = @v1 + dbo.fn_ann_S(@c, @a, '276', '', N'*', 0);
            EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @v = @v, @source = N'266 et 276', @regle = 'RC8';
            EXEC dbo.pr_ann_copie_n1 @c = @c, @a = @a, @art = @art, @ligne = @l;
            EXEC dbo.pr_ann_regle_m @c = @c, @a = @a, @art = @art, @ligne = @l, @col_aug = 3, @col_dim = 4, @comptes = '266', @exclues = '',
                 @registre = 0, @sans_registre = @sans_registre;
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @motif = N'variation du 276 sans contrat', @regle = 'RC8';
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @motif = N'échéance', @fmt = 'texte', @obligation = 'CONDITIONNELLE', @regle = 'RC8';
            INSERT INTO @codes (l) VALUES (@l);
        END;
    END;
    DECLARE @k TINYINT = 1;
    WHILE @k <= 5
    BEGIN
        DECLARE @t NVARCHAR (MAX) = (SELECT STRING_AGG(N'1|334-6|' + l + N'|' + CAST(@k AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @codes);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @k, @termes = @t;
        SET @k += 1;
    END;
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = 6, @motif = N'le modèle ne date pas le total', @regle = 'RC1', @fmt = 'texte';
    EXEC dbo.pr_ann_ligne_retiree @c = @c, @a = @a, @art = @art, @ligne = N'ECHEANCE', @regle = 'RC8',
         @motif = N'l’échéance se lit contrat par contrat';
    SET @k = 1;
    WHILE @k <= 2
    BEGIN
        DECLARE @aa VARCHAR (20) = CASE WHEN @k = 1 THEN @a ELSE @P END;
        DECLARE @tv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'TOTAL', @k);
        DECLARE @b1 DECIMAL (38, 12) = CASE WHEN @aa IS NOT NULL THEN dbo.fn_ann_S(@c, @aa, '266', '', N'*', 0) END,
                @b2 DECIMAL (38, 12) = CASE WHEN @aa IS NOT NULL THEN dbo.fn_ann_S(@c, @aa, '276', '', N'*', 0) END;
        IF @tv IS NOT NULL AND @b1 IS NOT NULL AND @b2 IS NOT NULL
        BEGIN
            DECLARE @e DECIMAL (38, 12) = @tv - (@b1 + @b2), @cle NVARCHAR (40) = N'334-6 colonne ' + CAST(@k AS NVARCHAR (2));
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_BILAN', @cle = @cle, @ecart = @e;
        END;
        SET @k += 1;
    END;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT l FROM @codes ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @l;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @x2 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, 2), @x3 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, 3),
                @x4 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, 4), @x5 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, 5),
                @x1 DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, 1);
        IF @x1 IS NOT NULL AND @x2 IS NOT NULL AND @x3 IS NOT NULL AND @x4 IS NOT NULL AND @x5 IS NOT NULL
        BEGIN
            DECLARE @eb DECIMAL (38, 12) = @x2 + @x3 - @x4 + @x5 - @x1, @cb NVARCHAR (120) = N'334-6 ' + @l;
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C334_BOUCLAGE', @cle = @cb, @ecart = @eb;
        END;
        FETCH NEXT FROM cur INTO @l;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

