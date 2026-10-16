
-- Regle DU (oracle, distributions_de) : la distribution par part de l'exercice @y anterieur a celui de N, colonne @k,
-- sur la table de l'arrete annuel de @y + 1 ; ecrit DIST_RESULTAT et DIST_CESSION.
CREATE   PROCEDURE dbo.pr_ann_distributions_de @c INT, @a VARCHAR (20), @k INT, @y INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '332-1', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @dn DATE = dbo.fn_ann_date(@c, @a);
    DECLARE @a_y VARCHAR (20) = dbo.fn_ann_annuel_de(@c, @y, @dn), @a_y1 VARCHAR (20) = dbo.fn_ann_annuel_de(@c, @y + 1, @dn);
    DECLARE @tous NVARCHAR (MAX) = NULL, @sy NVARCHAR (4) = CAST(@y AS NVARCHAR (4)), @sy1 NVARCHAR (4) = CAST(@y + 1 AS NVARCHAR (4));
    DECLARE @res TABLE (code VARCHAR (24), col TINYINT, etat VARCHAR (12), valeur DECIMAL (38, 12), motif NVARCHAR (MAX), ops NVARCHAR (MAX), formule NVARCHAR (MAX),
                        source NVARCHAR (MAX), nature VARCHAR (8), obligation VARCHAR (14));
    IF @a_y IS NULL
        SET @tous = N'aucun arrêté annuel de l’exercice ' + @sy + N' au dossier';
    ELSE IF @a_y1 IS NULL
    BEGIN
        DECLARE @apres VARCHAR (20) = dbo.fn_ann_annuel_de(@c, @y + 1, NULL);
        SET @tous = CASE WHEN @apres IS NOT NULL
            THEN N'l’arrêté annuel de l’exercice ' + @sy1 + N' (' + dbo.fn_ann_arrete_fr(@c, @apres) + N') est postérieur à l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a) + N' : la distribution du résultat de ' + @sy + N', payée en ' + @sy1 + N', n’est pas établie à cet arrêté'
            ELSE N'aucun arrêté annuel de l’exercice ' + @sy1 + N' au dossier : la distribution du résultat de ' + @sy + N' n’est pas en base' END;
    END;
    ELSE IF NOT EXISTS (SELECT 1 FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a_y1)
        SET @tous = N'l’arrêté annuel du ' + dbo.fn_ann_arrete_fr(@c, @a_y1) + N' de l’exercice ' + @sy1 + N' n’est pas un arrêté de mission : la distribution du résultat de ' + @sy + N' n’est pas en base';
    ELSE IF ISNULL((SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a_y1), '') <> @a_y
        SET @tous = N'l’arrêté N-1 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1) + N' n’est pas l’arrêté annuel du ' + dbo.fn_ann_arrete_fr(@c, @a_y) + N' de l’exercice ' + @sy;
    DECLARE @ici BIT = CASE WHEN @a_y1 = @a THEN 1 ELSE 0 END;
    DECLARE @attente TABLE (n INT IDENTITY, art VARCHAR (10), ligne NVARCHAR (120), col TINYINT);
    DECLARE @nlues INT = 1, @rn_b DECIMAL (38, 12) = 0, @pmv_b DECIMAL (38, 12) = 0;
    IF @tous IS NULL
    BEGIN
        DECLARE @dp_etat VARCHAR (12) = dbo.fn_ann_etat(@c, @a_y1, '333-3', N'DISTRIB_PREC', 1);
        IF @dp_etat IN ('LU', 'CALCULE', 'SAISI')
        BEGIN
            DECLARE @dp DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a_y1, '333-3', N'DISTRIB_PREC', 1);
            SET @tous = dbo.fn_ann_distrib_prec_motif(@c, @dp, @a_y, @a_y1);
            IF @tous IS NULL AND @dp <> 0
            BEGIN
                DECLARE @s129 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a_y1, '129', '', N'*', 0);
                IF @s129 IS NULL OR @s129 <> 0
                    SET @tous = N'paiements datés de ' + @sy1 + N' mêlant la distribution du résultat de ' + @sy + N' et des acomptes de ' + @sy1 + N' : leur montant par part n’est pas isolé';
                ELSE
                BEGIN
                    DECLARE @bas VARCHAR (10) = CONVERT(VARCHAR (10), dbo.fn_ann_date(@c, @a_y), 23), @haut VARCHAR (10) = CONVERT(VARCHAR (10), dbo.fn_ann_date(@c, @a_y1), 23);
                    DECLARE @tv DECIMAL (38, 12), @pp DECIMAL (38, 12);
                    SELECT @tv = ISNULL(SUM(distribution_totale), 0), @pp = ISNULL(SUM(distribution_par_part), 0) FROM dbo.v_distribution_par_part
                    WHERE entite = @entite AND LEFT(date_valeur, 10) > @bas AND LEFT(date_valeur, 10) <= @haut;
                    IF @tv <> @dp
                        SET @tous = N'distribution du résultat de ' + @sy + N' payée en ' + @sy1 + N' (' + dbo.fn_ann_format('montant', @dp) + N', registre des porteurs) : les paiements rapportés aux parts datés de '
                            + @sy1 + N' (' + dbo.fn_ann_format('montant', @tv) + N') ne la couvrent pas, un paiement n’étant rapporté aux parts que s’il est daté d’un arrêté : son montant par part n’est pas établi';
                    ELSE
                    BEGIN
                        SET @nlues = 3;
                        DECLARE @ie VARCHAR (12) = dbo.fn_ann_etat(@c, @a_y1, '335-12', N'I_D_T', 2), @iie VARCHAR (12) = dbo.fn_ann_etat(@c, @a_y1, '335-12', N'II_D_T', 2);
                        DECLARE @iv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a_y1, '335-12', N'I_D_T', 2), @iiv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a_y1, '335-12', N'II_D_T', 2);
                        IF @iiv = 0 SET @rn_b = @pp;
                        ELSE IF @iv = 0 SET @pmv_b = @pp;
                        ELSE IF @iv IS NOT NULL AND @iiv IS NOT NULL
                            SET @tous = N'sommes distribuables de ' + @sy + N' sur le résultat net et sur les plus-values toutes 2 non nulles (335-12, colonne Exercice N-1 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1) + N') : la part de la distribution qui va à chacune n’est pas établie';
                        ELSE
                        BEGIN
                            IF @ie IN ('A_REMPLIR', 'EN_ATTENTE') INSERT INTO @attente (art, ligne, col) VALUES ('335-12', N'I_D_T', 2);
                            IF @iie IN ('A_REMPLIR', 'EN_ATTENTE') INSERT INTO @attente (art, ligne, col) VALUES ('335-12', N'II_D_T', 2);
                            IF NOT EXISTS (SELECT 1 FROM @attente)
                                SET @tous = N'sommes distribuables de ' + @sy + N' non établies au 335-12 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1);
                        END;
                    END;
                END;
            END;
        END;
        ELSE IF @dp_etat IN ('A_REMPLIR', 'EN_ATTENTE')
            INSERT INTO @attente (art, ligne, col) VALUES ('333-3', N'DISTRIB_PREC', 1);
        ELSE
            SET @tous = N'distribution de l’exercice précédent non établie au 333-3 de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1);
    END;
    DECLARE @j INT = 1, @code VARCHAR (24), @col TINYINT, @sid INT;
    WHILE @j <= 2
    BEGIN
        SELECT @code = CASE @j WHEN 1 THEN 'DIST_RESULTAT' ELSE 'DIST_CESSION' END, @col = CASE @j WHEN 1 THEN 3 ELSE 5 END;
        SET @sid = dbo.fn_ann_saisie_annee(@c, @a, @code, @y);
        IF @tous IS NOT NULL
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @motif = @tous, @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
        ELSE
        BEGIN
            DECLARE @ae VARCHAR (12) = dbo.fn_ann_etat(@c, @a_y1, '335-12', N'ACPT_N1_TOTAL', @col);
            DECLARE @att TABLE (n INT IDENTITY, art VARCHAR (10), ligne NVARCHAR (120), col TINYINT);
            DELETE @att;
            INSERT INTO @att (art, ligne, col) SELECT art, ligne, col FROM @attente ORDER BY n;
            DECLARE @skip BIT = 0;
            IF ISNULL(@ae, '') NOT IN ('LU', 'CALCULE', 'SAISI')
            BEGIN
                IF @ae IS NULL OR @ae NOT IN ('A_REMPLIR', 'EN_ATTENTE')
                BEGIN
                    DECLARE @m1 NVARCHAR (400) = N'acomptes de ' + @sy + N' non établis au tableau des acomptes de l’exercice précédent de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1);
                    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @motif = @m1, @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
                    SET @skip = 1;
                END;
                ELSE INSERT INTO @att (art, ligne, col) VALUES ('335-12', N'ACPT_N1_TOTAL', @col);
            END;
            IF @skip = 0
            BEGIN
                DECLARE @f NVARCHAR (MAX) = N'335-12 ACPT_N1_TOTAL[' + CAST(@col AS NVARCHAR (2)) + N'] + distribution du résultat de ' + @sy + N' payée en ' + @sy1
                    + N', par part (v_distribution_par_part ; 333-3 DISTRIB_PREC[1]' + CASE WHEN @nlues > 1 THEN N', 335-12 I_D_T[2] et II_D_T[2]' ELSE N'' END + N')';
                IF EXISTS (SELECT 1 FROM @att)
                BEGIN
                    DECLARE @liste NVARCHAR (MAX) = (SELECT STRING_AGG(dbo.fn_ann_designer(@c, @a_y1, art, ligne, col), N' ; ') WITHIN GROUP (ORDER BY n) FROM @att);
                    IF @ici = 1
                    BEGIN
                        DECLARE @ops NVARCHAR (MAX) = (SELECT STRING_AGG(art + N'|' + ligne + N'|' + CAST(col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @att);
                        DECLARE @m2 NVARCHAR (MAX) = N'opérandes de cet arrêté à remplir ou en attente : ' + @liste;
                        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @etat = 'EN_ATTENTE', @nature = 'calcul', @obligation = 'SANS',
                             @ops = @ops, @motif = @m2, @formule = @f, @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
                    END;
                    ELSE
                    BEGIN
                        DECLARE @m3 NVARCHAR (MAX) = N'non établie à l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1) + N' (' + @liste + N' à remplir ou en attente) : à remplir à cet arrêté ou à saisir ici';
                        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @motif = @m3, @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
                    END;
                END;
                ELSE
                BEGIN
                    DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a_y1, '335-12', N'ACPT_N1_TOTAL', @col) + CASE WHEN @col = 3 THEN @rn_b ELSE @pmv_b END;
                    DECLARE @src NVARCHAR (MAX) = CASE WHEN @ici = 1 THEN N'cet arrêté' ELSE N'annexe de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1) END + N' : acomptes de ' + @sy
                        + N' par part (335-12, ligne Total acomptes du tableau de l’exercice précédent, colonne ' + CAST(@col AS NVARCHAR (2)) + N') et distribution du résultat de '
                        + @sy + N' payée en ' + @sy1 + N' (333-3, rapprochée du registre des porteurs, rapportée aux parts en circulation à la date du paiement, ventilée par le 335-12 colonne Exercice N-1), par part';
                    DECLARE @f2 NVARCHAR (MAX) = CASE WHEN @ici = 1 THEN @f ELSE N'table de l’arrêté ' + @a_y1 + N' : ' + @f END;
                    DECLARE @o2 NVARCHAR (MAX) = CASE WHEN @ici = 1 THEN N'335-12|ACPT_N1_TOTAL|' + CAST(@col AS NVARCHAR (2)) + N';333-3|DISTRIB_PREC|1'
                        + CASE WHEN @nlues > 1 THEN N';335-12|I_D_T|2;335-12|II_D_T|2' ELSE N'' END END;
                    DECLARE @na VARCHAR (8) = CASE WHEN @ici = 1 THEN 'calcul' ELSE 'source' END, @ob VARCHAR (14) = CASE WHEN @ici = 1 THEN 'SANS' ELSE 'IMPOSEE' END;
                    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @etat = 'CALCULE', @valeur = @v, @source = @src, @formule = @f2,
                         @ops = @o2, @nature = @na, @obligation = @ob, @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
                END;
            END;
        END;
        SET @j += 1;
    END;
END;

GO

