
CREATE   PROCEDURE dbo.pr_ann_acomptes @c INT, @a VARCHAR (20), @prefixe VARCHAR (10), @k INT, @x VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-12', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @ordre DECIMAL (19, 6) = CASE WHEN @k = 1 THEN 23 ELSE 24 END;
    DECLARE @lib NVARCHAR (500) = N'Acomptes versés au titre de l''exercice' + CASE WHEN @k = 1 THEN N'' ELSE N' précédent' END;
    DECLARE @tot NVARCHAR (120) = @prefixe + N'_TOTAL';
    DECLARE @t129 DECIMAL (38, 12) = CASE WHEN @x IS NOT NULL THEN dbo.fn_ann_S(@c, @x, '129', '', N'*', 0) END;
    DECLARE @net_ops NVARCHAR (100) = N'333-1|SD_AC_NET|' + CAST(@k AS NVARCHAR (2)), @pmv_ops NVARCHAR (100) = N'333-1|SD_AC_PMV|' + CAST(@k AS NVARCHAR (2));
    DECLARE @cn_connue BIT = dbo.fn_ann_connue(@c, @a, '333-1', N'SD_AC_NET', @k), @cp_connue BIT = dbo.fn_ann_connue(@c, @a, '333-1', N'SD_AC_PMV', @k);
    DECLARE @cn DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, '333-1', N'SD_AC_NET', @k), @cp DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, '333-1', N'SD_AC_PMV', @k);
    DECLARE @lignes TABLE (n INT IDENTITY, l NVARCHAR (120));
    DECLARE @neant_333_1 BIT = CASE WHEN @t129 IS NULL AND @cn_connue = 1 AND @cp_connue = 1 AND @cn = 0 AND @cp = 0 THEN 1 ELSE 0 END;
    DECLARE @l NVARCHAR (120), @col TINYINT, @src NVARCHAR (MAX), @fmt VARCHAR (10), @t NVARCHAR (MAX), @v DECIMAL (38, 12);
    IF @t129 = 0 OR @neant_333_1 = 1
    BEGIN
        SET @l = @prefixe + N':NEANT';
        INSERT INTO @lignes (l) VALUES (@l);
        IF @neant_333_1 = 1
        BEGIN
            SET @src = dbo.fn_ann_designer(@c, @a, '333-1', N'SD_AC_NET', @k) + N', et ' + dbo.fn_ann_designer(@c, @a, '333-1', N'SD_AC_PMV', @k) + N', nulles : aucun acompte';
            DECLARE @o2 NVARCHAR (200) = @net_ops + N';' + @pmv_ops;
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'CALCULE', @fmt = 'texte', @texte = N'Néant', @source = @src,
                 @regle = 'ACPT', @nature = 'calcul', @obligation = 'SANS', @ops = @o2, @libelle = @lib, @ordre = @ordre;
        END;
        ELSE
        BEGIN
            SET @src = N'solde du 129 nul à l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @x) + N' : aucun acompte payé';
            EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @source = @src, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        END;
        SET @col = 2;
        WHILE @col <= 7
        BEGIN
            SET @fmt = CASE WHEN @col IN (3, 5, 7) THEN 'unitaire' ELSE 'montant' END;
            EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = N'aucun acompte', @fmt = @fmt, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
            SET @col += 1;
        END;
    END;
    ELSE
    BEGIN
        DECLARE @prev VARCHAR (20) = CASE WHEN @x IS NOT NULL THEN dbo.fn_ann_annuel_precedent(@c, @x) END;
        DECLARE @bas VARCHAR (10) = CONVERT(VARCHAR (10), dbo.fn_ann_date(@c, @prev), 23), @haut VARCHAR (10) = CONVERT(VARCHAR (10), dbo.fn_ann_date(@c, @x), 23);
        DECLARE @dist TABLE (i INT IDENTITY, date_valeur VARCHAR (40), totale DECIMAL (38, 12), par_part DECIMAL (38, 12));
        IF @bas IS NOT NULL AND @haut IS NOT NULL
            INSERT INTO @dist (date_valeur, totale, par_part)
            SELECT date_valeur, distribution_totale, distribution_par_part FROM dbo.v_distribution_par_part
            WHERE entite = @entite AND LEFT(date_valeur, 10) > @bas AND LEFT(date_valeur, 10) <= @haut ORDER BY date_valeur;
        DECLARE @nd INT = (SELECT COUNT(*) FROM @dist);
        IF @t129 IS NOT NULL AND @nd > 0 AND (SELECT SUM(totale) FROM @dist) = @t129
        BEGIN
            DECLARE @tout_net BIT = CASE WHEN @cp_connue = 1 AND @cp = 0 THEN 1 ELSE 0 END;
            DECLARE @tout_pmv BIT = CASE WHEN @tout_net = 0 AND @cn_connue = 1 AND @cn = 0 THEN 1 ELSE 0 END;
            DECLARE @i INT = 1, @dv VARCHAR (40), @v6 DECIMAL (38, 12), @pp DECIMAL (38, 12), @nrang INT;
            WHILE @i <= @nd
            BEGIN
                SELECT @dv = date_valeur, @v6 = totale, @pp = par_part FROM @dist WHERE i = @i;
                SET @l = @prefixe + N':' + LEFT(@dv, 10); SET @nrang = 2;
                WHILE EXISTS (SELECT 1 FROM @lignes WHERE l = @l)
                    SELECT @l = @prefixe + N':' + LEFT(@dv, 10) + N':' + CAST(@nrang AS NVARCHAR (4)), @nrang += 1;
                DECLARE @autres_net NVARCHAR (MAX) = (SELECT STRING_AGG(N'-1|335-12|' + l + N'|2', N';') WITHIN GROUP (ORDER BY n) FROM @lignes);
                DECLARE @autres_pmv NVARCHAR (MAX) = (SELECT STRING_AGG(N'-1|335-12|' + l + N'|4', N';') WITHIN GROUP (ORDER BY n) FROM @lignes);
                INSERT INTO @lignes (l) VALUES (@l);
                DECLARE @df NVARCHAR (40) = dbo.fn_ann_date_fr(@dv);
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @texte = @df, @fmt = 'texte',
                     @source = N'registre des porteurs, date du paiement', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @etat = 'LU', @valeur = @v6,
                     @source = N'registre des porteurs, montant total du paiement', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 7, @etat = 'LU', @valeur = @pp, @fmt = 'unitaire',
                     @source = N'registre des porteurs, montant du paiement par part en circulation', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                IF @tout_net = 1 OR @tout_pmv = 1
                BEGIN
                    DECLARE @nul NVARCHAR (100) = CASE WHEN @tout_net = 1 THEN @pmv_ops ELSE @net_ops END;
                    SET @src = dbo.fn_ann_designer(@c, @a, '333-1', CASE WHEN @tout_net = 1 THEN N'SD_AC_PMV' ELSE N'SD_AC_NET' END, @k)
                        + N', nulle : le paiement va en entier ' + CASE WHEN @tout_net = 1 THEN N'au résultat net' ELSE N'aux plus-values' END;
                    DECLARE @f6 NVARCHAR (200) = N'+ 335-12 ' + @l + N'[6]', @o6 NVARCHAR (300) = @nul + N';335-12|' + @l + N'|6';
                    DECLARE @va DECIMAL (38, 12) = CASE WHEN @tout_net = 1 THEN @v6 ELSE 0 END, @vb DECIMAL (38, 12) = CASE WHEN @tout_net = 1 THEN 0 ELSE @v6 END;
                    DECLARE @fa NVARCHAR (200) = CASE WHEN @tout_net = 1 THEN @f6 ELSE N'0' END, @fb NVARCHAR (200) = CASE WHEN @tout_net = 1 THEN N'0' ELSE @f6 END;
                    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @etat = 'CALCULE', @valeur = @va, @source = @src, @ops = @o6,
                         @formule = @fa, @regle = 'ACPT', @nature = 'calcul', @obligation = 'SANS', @libelle = @lib, @ordre = @ordre;
                    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @etat = 'CALCULE', @valeur = @vb, @source = @src, @ops = @o6,
                         @formule = @fb, @regle = 'ACPT', @nature = 'calcul', @obligation = 'SANS', @libelle = @lib, @ordre = @ordre;
                END;
                ELSE IF @i < @nd
                BEGIN
                    DECLARE @ms NVARCHAR (MAX) = N'ventilation du paiement du ' + @df + N' entre résultat net et plus-values (le dernier paiement se déduit du 333-1)';
                    EXEC dbo.pr_ann_acpt_a_saisir @c = @c, @a = @a, @k = @k, @prefixe = @prefixe, @l = @l, @col = 2, @motif = @ms, @libelle = @lib, @ordre = @ordre;
                    SET @t = N'1|335-12|' + @l + N'|6;-1|335-12|' + @l + N'|2';
                    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @termes = @t, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                END;
                ELSE
                BEGIN
                    SET @t = N'-1|' + @net_ops + ISNULL(N';' + @autres_net, N'');
                    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @termes = @t, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                    SET @t = N'-1|' + @pmv_ops + ISNULL(N';' + @autres_pmv, N'');
                    EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @termes = @t, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                END;
                DECLARE @j INT = 1, @cu TINYINT, @cs TINYINT;
                WHILE @j <= 2
                BEGIN
                    SELECT @cu = CASE @j WHEN 1 THEN 3 ELSE 5 END, @cs = CASE @j WHEN 1 THEN 2 ELSE 4 END;
                    DECLARE @op NVARCHAR (200) = N'335-12|' + @l + N'|' + CAST(@cs AS NVARCHAR (2));
                    IF dbo.fn_ann_connue(@c, @a, @art, @l, @cs) = 1
                    BEGIN
                        SET @v = CAST(CAST(dbo.fn_ann_val(@c, @a, @art, @l, @cs) AS FLOAT) * CAST(@pp AS FLOAT) / CAST(@v6 AS FLOAT) AS DECIMAL (38, 12));
                        SET @src = N'colonne ' + CAST(@cs AS NVARCHAR (2)) + N' multipliée par le montant du paiement par part et divisée par son montant total';
                        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @cu, @etat = 'CALCULE', @valeur = @v, @fmt = 'unitaire', @source = @src,
                             @ops = @op, @nature = 'calcul', @obligation = 'SANS', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                    END;
                    ELSE
                        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @cu, @etat = 'EN_ATTENTE', @fmt = 'unitaire', @ops = @op,
                             @nature = 'calcul', @obligation = 'SANS', @motif = N'montant total en attente', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
                    SET @j += 1;
                END;
                SET @i += 1;
            END;
        END;
        ELSE
        BEGIN
            SET @l = @prefixe + N':SAISIE';
            INSERT INTO @lignes (l) VALUES (@l);
            DECLARE @mo NVARCHAR (200) = N'paiement d’acompte non rapproché des paiements du registre des porteurs';
            DECLARE @m1 NVARCHAR (300) = @mo + N' : date de paiement', @mu NVARCHAR (300) = @mo + N' : montant unitaire';
            EXEC dbo.pr_ann_acpt_a_saisir @c = @c, @a = @a, @k = @k, @prefixe = @prefixe, @l = @l, @col = 1, @motif = @m1, @fmt = 'texte', @nature = 'texte', @libelle = @lib, @ordre = @ordre;
            SET @t = N'-1|' + @net_ops;
            EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @termes = @t, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
            SET @t = N'-1|' + @pmv_ops;
            EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @termes = @t, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
            EXEC dbo.pr_ann_acpt_a_saisir @c = @c, @a = @a, @k = @k, @prefixe = @prefixe, @l = @l, @col = 3, @motif = @mu, @fmt = 'unitaire', @libelle = @lib, @ordre = @ordre;
            EXEC dbo.pr_ann_acpt_a_saisir @c = @c, @a = @a, @k = @k, @prefixe = @prefixe, @l = @l, @col = 5, @motif = @mu, @fmt = 'unitaire', @libelle = @lib, @ordre = @ordre;
            SET @t = N'1|335-12|' + @l + N'|2;1|335-12|' + @l + N'|4';
            EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @termes = @t, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
            SET @t = N'1|335-12|' + @l + N'|3;1|335-12|' + @l + N'|5';
            EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 7, @termes = @t, @fmt = 'unitaire', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        END;
    END;
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @tot, @col = 1, @motif = N'la ligne Total acomptes porte son libellé dans la colonne des dates',
         @fmt = 'texte', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
    DECLARE @cols TABLE (n INT, col TINYINT);
    INSERT INTO @cols VALUES (1, 2), (2, 3), (3, 4), (4, 5), (5, 7);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT col FROM @cols ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @col;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @fmt = CASE WHEN @col IN (3, 5, 7) THEN 'unitaire' ELSE 'montant' END;
        SET @t = (SELECT STRING_AGG(N'1|335-12|' + l + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @lignes);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @tot, @col = @col, @termes = @t, @fmt = @fmt, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        IF dbo.fn_ann_etat(@c, @a, @art, @tot, @col) = 'SANS_OBJET'
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @tot, @col = @col, @etat = 'CALCULE', @valeur = 0, @fmt = @fmt, @source = N'aucun acompte',
                 @nature = 'calcul', @obligation = 'SANS', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        FETCH NEXT FROM cur INTO @col;
    END;
    CLOSE cur; DEALLOCATE cur;
    IF @t129 IS NULL
    BEGIN
        SET @t = (SELECT STRING_AGG(N'1|335-12|' + l + N'|6', N';') WITHIN GROUP (ORDER BY n) FROM @lignes);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @tot, @col = 6, @termes = @t, @fmt = 'montant', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        IF dbo.fn_ann_etat(@c, @a, @art, @tot, 6) = 'SANS_OBJET'
        BEGIN
            DECLARE @o3 NVARCHAR (200) = @net_ops + N';' + @pmv_ops;
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @tot, @col = 6, @etat = 'CALCULE', @valeur = 0, @fmt = 'montant', @source = N'aucun acompte (333-1)',
                 @nature = 'calcul', @obligation = 'SANS', @ops = @o3, @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        END;
    END;
    ELSE
    BEGIN
        SET @src = N'solde du 129 à l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @x) + N' : acomptes payés, régularisations (198) exclues';
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @tot, @col = 6, @etat = 'LU', @valeur = @t129, @source = @src, @nature = 'calcul',
             @obligation = 'SANS', @regle = 'ACPT', @libelle = @lib, @ordre = @ordre;
        DECLARE @nl INT = (SELECT COUNT(*) FROM @lignes), @nv INT, @sv DECIMAL (38, 12);
        SELECT @nv = COUNT(dbo.fn_ann_val(@c, @a, @art, l, 6)), @sv = SUM(dbo.fn_ann_val(@c, @a, @art, l, 6)) FROM @lignes;
        IF @nl > 0 AND (SELECT l FROM @lignes WHERE n = 1) NOT LIKE N'%NEANT' AND @nv = @nl
        BEGIN
            DECLARE @e DECIMAL (38, 12) = @sv - @t129;
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S335_12_ACOMPTES', @cle = @tot, @ecart = @e;
        END;
    END;
END;

GO

