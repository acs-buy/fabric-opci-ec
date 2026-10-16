
CREATE   PROCEDURE dbo.pr_ann_a_336_2 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @n_i1 NVARCHAR (MAX) = dbo.fn_ann_nom_etat('A_IMMO_1'), @n_i3 NVARCHAR (MAX) = dbo.fn_ann_nom_etat('A_IMMO_3'),
            @n_i4 NVARCHAR (MAX) = dbo.fn_ann_nom_etat('A_IMMO_4');
    DECLARE @p_i1 NVARCHAR (MAX) = N'de la ligne ' + @n_i1 + N' du bilan', @p_i34 NVARCHAR (MAX) = N'des lignes ' + @n_i3 + N' et ' + @n_i4 + N' du bilan',
            @s_i1 NVARCHAR (MAX) = N'bilan, ligne ' + @n_i1 + N' nulle';
    DECLARE @art VARCHAR (10) = '336-2', @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @dn DATE = dbo.fn_ann_date(@c, @a);
    DECLARE @l NVARCHAR (120), @col TINYINT, @src NVARCHAR (MAX), @v DECIMAL (38, 12), @tx NVARCHAR (2000), @m NVARCHAR (MAX), @lib NVARCHAR (500);
    -- les actifs sortis au plus tard de N (oracle, actifs_detenus)
    DECLARE @sortis TABLE (code VARCHAR (40) PRIMARY KEY);
    INSERT INTO @sortis SELECT DISTINCT code_actif FROM dbo.mouvement_actif
    WHERE entite = @entite AND nature IN ('CESSION', 'SORTIE') AND date_mouvement IS NOT NULL AND CAST(date_mouvement AS DATE) <= @dn;

    -- ------------------------------------------------------------ IMMEUBLES ET DROITS REELS
    DECLARE @imm TABLE (n INT IDENTITY, code VARCHAR (40), adresse NVARCHAR (2000), surface DECIMAL (38, 12), secteur NVARCHAR (2000),
                        date_acq DATE, prix DECIMAL (38, 12), valeur DECIMAL (38, 12));
    INSERT INTO @imm (code, adresse, surface, secteur, date_acq, prix, valeur)
    SELECT code_actif, adresse, surface_m2, secteur, date_acquisition, prix_de_revient, valeur_actuelle FROM dbo.v_inventaire_immeubles
    WHERE entite = @entite AND arrete = @a ORDER BY dbo.fn_ann_cle_naturelle(code_actif) COLLATE Latin1_General_100_BIN2;
    DECLARE @couts DECIMAL (38, 12) = dbo.fn_ann_Sl(@c, @a, '21,22,23', '');
    DECLARE @imm_actif BIT = 0;
    IF NOT EXISTS (SELECT 1 FROM @imm)
    BEGIN
        INSERT INTO @imm (code, adresse, surface, secteur, date_acq, prix, valeur)
        SELECT x.code, x.adresse, x.surface_m2, x.secteur, x.date_acquisition, x.prix_de_revient, NULL FROM dbo.actif x
        WHERE x.entite_detentrice = @entite AND LEFT(ISNULL(x.poste_bilan, ''), 2) IN ('21', '22', '23')
          AND x.code NOT IN (SELECT code FROM @sortis) AND (x.date_acquisition IS NULL OR x.date_acquisition <= @dn)
        ORDER BY dbo.fn_ann_cle_naturelle(x.code) COLLATE Latin1_General_100_BIN2;
        IF EXISTS (SELECT 1 FROM @imm) SET @imm_actif = 1;
    END;
    DECLARE @orig NVARCHAR (200) = CASE WHEN @imm_actif = 1 THEN N'registre des actifs' ELSE N'inventaire des immeubles valorisés à l’arrêté' END;
    DECLARE @ni INT = (SELECT COUNT(*) FROM @imm), @nuls INT, @somme DECIMAL (38, 12);
    DECLARE @lu5 BIT, @motif5 NVARCHAR (MAX), @lu6 BIT, @motif6 NVARCHAR (MAX), @att DECIMAL (38, 12);
    SELECT @nuls = SUM(CASE WHEN prix IS NULL THEN 1 ELSE 0 END), @somme = ISNULL(SUM(prix), 0) FROM @imm;
    EXEC dbo.pr_ann_colonne_vue @c = @c, @a = @a, @n = @ni, @nuls = @nuls, @somme = @somme, @cle = N'prix_de_revient', @attendu = @couts,
         @poste = N'du solde des comptes 21, 22 et 23', @rapproche = N'prix de revient', @lue = @lu5 OUTPUT, @motif = @motif5 OUTPUT;
    SET @att = dbo.fn_ann_E(@c, @a, 'A_IMMO_1', 1);
    SELECT @nuls = SUM(CASE WHEN valeur IS NULL THEN 1 ELSE 0 END), @somme = ISNULL(SUM(valeur), 0) FROM @imm;
    EXEC dbo.pr_ann_colonne_vue @c = @c, @a = @a, @n = @ni, @nuls = @nuls, @somme = @somme, @cle = N'valeur_actuelle', @attendu = @att,
         @poste = @p_i1, @rapproche = N'valeur des immeubles', @lue = @lu6 OUTPUT, @motif = @motif6 OUTPUT;
    IF @imm_actif = 1
        SELECT @lu6 = 0, @motif6 = N'aucun immeuble valorisé à l’arrêté (aucune valeur actuelle enregistrée) : immeuble détenu selon le registre des actifs, valeur actuelle à remplir';
    DECLARE @codes TABLE (n INT IDENTITY, l NVARCHAR (120));
    DECLARE @i INT = 1, @code VARCHAR (40), @ad NVARCHAR (2000), @su DECIMAL (38, 12), @se NVARCHAR (2000), @da DATE, @pr DECIMAL (38, 12), @va DECIMAL (38, 12);
    WHILE @i <= @ni
    BEGIN
        SELECT @code = code, @ad = adresse, @su = surface, @se = secteur, @da = date_acq, @pr = prix, @va = valeur FROM @imm WHERE n = @i;
        SET @l = N'IMM:' + @code; SET @lib = @code;
        INSERT INTO @codes (l) VALUES (@l);
        -- colonne 1 : adresse
        IF @ad IS NULL EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = N'donnée absente du registre des actifs : adresse', @fmt = 'texte', @ordre = 1, @libelle = @lib, @regle = 'RC3';
        ELSE BEGIN SET @src = @orig + N', adresse'; EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @fmt = 'texte', @texte = @ad, @source = @src, @ordre = 1, @libelle = @lib, @regle = 'RC3'; END;
        -- colonne 2 : surface
        IF @su IS NULL EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @motif = N'donnée absente du registre des actifs : surface', @fmt = 'surface', @ordre = 1, @libelle = @lib, @regle = 'RC3';
        ELSE BEGIN SET @src = @orig + N', surface'; EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @etat = 'LU', @valeur = @su, @fmt = 'surface', @source = @src, @ordre = 1, @libelle = @lib, @regle = 'RC3'; END;
        -- colonne 3 : secteur
        IF @se IS NULL EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @motif = N'donnée absente du registre des actifs : secteur', @fmt = 'texte', @ordre = 1, @libelle = @lib, @regle = 'RC3';
        ELSE BEGIN SET @src = @orig + N', secteur'; EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @etat = 'LU', @fmt = 'texte', @texte = @se, @source = @src, @ordre = 1, @libelle = @lib, @regle = 'RC3'; END;
        -- colonne 4 : date d'acquisition
        IF @da IS NULL EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @motif = N'donnée absente du registre des actifs : date d’acquisition', @fmt = 'texte', @ordre = 1, @libelle = @lib, @regle = 'RC3';
        ELSE BEGIN SET @src = @orig + N', date d’acquisition'; SET @tx = dbo.fn_ann_date_fr(CONVERT(NVARCHAR (10), @da, 23));
                   EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @etat = 'LU', @fmt = 'texte', @texte = @tx, @source = @src, @ordre = 1, @libelle = @lib, @regle = 'RC3'; END;
        -- colonne 5 : prix de revient (regle RV)
        IF @lu5 = 0 EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @motif = @motif5, @fmt = 'montant', @ordre = 1, @libelle = @lib, @regle = 'RV';
        ELSE IF @pr IS NULL EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @motif = N'donnée absente du registre des actifs : prix de revient', @fmt = 'montant', @ordre = 1, @libelle = @lib, @regle = 'RC3';
        ELSE BEGIN SET @src = @orig + N', prix de revient'; EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @etat = 'LU', @valeur = @pr, @source = @src, @ordre = 1, @libelle = @lib, @regle = 'RC3'; END;
        -- colonne 6 : valeur actuelle (regle RV)
        IF @lu6 = 0 EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @motif = @motif6, @fmt = 'montant', @ordre = 1, @libelle = @lib, @regle = 'RV';
        ELSE IF @va IS NULL EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @motif = N'donnée absente du registre des actifs : valeur actuelle', @fmt = 'montant', @ordre = 1, @libelle = @lib, @regle = 'RC3';
        ELSE BEGIN SET @src = @orig + N', valeur actuelle'; EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @etat = 'LU', @valeur = @va, @source = @src, @ordre = 1, @libelle = @lib, @regle = 'RC3'; END;
        -- colonne 7 : % de l'actif net
        EXEC dbo.pr_ann_pct @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 7, @n_art = @art, @n_ligne = @l, @n_col = 6, @regle = 'RC3', @ordre = 1, @libelle = @lib;
        SET @i += 1;
    END;
    IF @ni = 0
    BEGIN
        DECLARE @b DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_1', 1);
        IF @b = 0
        BEGIN
            INSERT INTO @codes (l) VALUES (N'IMM:NEANT');
            EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = N'IMM:NEANT', @col = 1, @source = @s_i1, @libelle = N'Néant', @ordre = 1, @regle = 'RC3';
            SET @col = 2;
            WHILE @col <= 7
            BEGIN
                EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'IMM:NEANT', @col = @col, @motif = N'aucun immeuble', @libelle = N'Néant', @ordre = 1, @regle = 'RC3';
                SET @col += 1;
            END;
        END;
        ELSE
        BEGIN
            INSERT INTO @codes (l) VALUES (N'IMM:SAISIE');
            SET @m = CASE WHEN @b IS NOT NULL THEN N'immeuble au bilan (ligne ' + @n_i1 + N' non nulle) absent de l’inventaire et du registre des actifs'
                          ELSE N'arrêté sans balance : aucun immeuble à l’inventaire ni au registre des actifs, et l’absence d’immeuble n’est pas établie par le bilan' END;
            DECLARE @fm TABLE (col TINYINT, fmt VARCHAR (10));
            INSERT INTO @fm VALUES (1, 'texte'), (2, 'surface'), (3, 'texte'), (4, 'texte'), (5, 'montant'), (6, 'montant');
            DECLARE @f VARCHAR (10);
            DECLARE cf CURSOR LOCAL FAST_FORWARD FOR SELECT col, fmt FROM @fm ORDER BY col;
            OPEN cf; FETCH NEXT FROM cf INTO @col, @f;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'IMM:SAISIE', @col = @col, @motif = @m, @fmt = @f, @libelle = N'Immeuble à inventorier', @ordre = 1, @regle = 'RC3';
                FETCH NEXT FROM cf INTO @col, @f;
            END;
            CLOSE cf; DEALLOCATE cf;
            EXEC dbo.pr_ann_pct @c = @c, @a = @a, @art = @art, @ligne = N'IMM:SAISIE', @col = 7, @n_art = @art, @n_ligne = N'IMM:SAISIE', @n_col = 6, @regle = 'RC3',
                 @libelle = N'Immeuble à inventorier', @ordre = 1;
        END;
    END;
    SET @col = 1;
    WHILE @col <= 4
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'IMM_TOTAL', @col = @col, @motif = N'le total ne porte que les montants', @regle = 'RC3', @ordre = 1, @libelle = N'Total des immeubles';
        SET @col += 1;
    END;
    DECLARE @t NVARCHAR (MAX);
    SET @col = 5;
    WHILE @col <= 6
    BEGIN
        SET @t = (SELECT STRING_AGG(N'1|336-2|' + l + N'|' + CAST(@col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @codes);
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'IMM_TOTAL', @col = @col, @termes = @t, @regle = 'RC3', @ordre = 1, @libelle = N'Total des immeubles';
        SET @col += 1;
    END;
    EXEC dbo.pr_ann_pct @c = @c, @a = @a, @art = @art, @ligne = N'IMM_TOTAL', @col = 7, @n_art = @art, @n_ligne = N'IMM_TOTAL', @n_col = 6, @regle = 'RC3',
         @libelle = N'Total des immeubles', @ordre = 1;

    -- ------------------------------------------------------------ FILIALES ET PARTICIPATIONS
    DECLARE @fil TABLE (n INT IDENTITY, fille VARCHAR (20), denomination NVARCHAR (400), controle NVARCHAR (200), immeubles INT,
                        cout DECIMAL (38, 12), valeur DECIMAL (38, 12), difference DECIMAL (38, 12), classe VARCHAR (3), ordre DECIMAL (19, 6), groupe VARCHAR (40));
    INSERT INTO @fil (fille, denomination, controle, immeubles, cout, valeur, difference)
    SELECT entite_fille, denomination, controle_r214_83, immeubles_detenus, cout_de_revient_frais_exclus, valeur_actuelle_titres, difference_estimation
    FROM dbo.v_inventaire_filiales WHERE entite = @entite AND arrete = @a ORDER BY dbo.fn_ann_cle_naturelle(entite_fille) COLLATE Latin1_General_100_BIN2;
    DECLARE @fil_actif BIT = 0;
    IF NOT EXISTS (SELECT 1 FROM @fil)
    BEGIN
        INSERT INTO @fil (fille, denomination, controle, immeubles, cout, valeur, difference)
        SELECT v.lie, ISNULL(e.denomination, v.lie),
               CASE ep.controlee WHEN 1 THEN N'contrôlée' WHEN 0 THEN N'non contrôlée' END,
               (SELECT COUNT(*) FROM dbo.actif y WHERE y.entite_detentrice = v.lie), NULL, NULL, NULL
        FROM (SELECT DISTINCT x.entite_liee AS lie FROM dbo.actif x
              WHERE x.entite_detentrice = @entite AND LEFT(ISNULL(x.poste_bilan, ''), 2) = '25' AND ISNULL(x.entite_liee, '') <> ''
                AND x.code NOT IN (SELECT code FROM @sortis) AND (x.date_acquisition IS NULL OR x.date_acquisition <= @dn)) v
        LEFT JOIN dbo.ref_entite e ON e.code = v.lie
        LEFT JOIN dbo.eligibilite_participation ep ON ep.entite_mere = @entite AND ep.entite_fille = v.lie
        ORDER BY dbo.fn_ann_cle_naturelle(v.lie) COLLATE Latin1_General_100_BIN2;
        IF EXISTS (SELECT 1 FROM @fil) SET @fil_actif = 1;
    END;
    DECLARE @b3 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_3', 1), @b4 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_4', 1);
    DECLARE @nf INT = (SELECT COUNT(*) FROM @fil), @lu4 BIT, @motif4 NVARCHAR (MAX), @lu5f BIT, @motif5f NVARCHAR (MAX);
    SET @att = dbo.fn_ann_Sl(@c, @a, '252,254', '');
    SELECT @nuls = SUM(CASE WHEN cout IS NULL THEN 1 ELSE 0 END), @somme = ISNULL(SUM(cout), 0) FROM @fil;
    EXEC dbo.pr_ann_colonne_vue @c = @c, @a = @a, @n = @nf, @nuls = @nuls, @somme = @somme, @cle = N'cout_de_revient_frais_exclus', @attendu = @att,
         @poste = N'du solde des comptes 252 et 254', @rapproche = N'coût des titres', @lue = @lu4 OUTPUT, @motif = @motif4 OUTPUT;
    SET @att = CASE WHEN @b3 IS NULL OR @b4 IS NULL THEN NULL ELSE @b3 + @b4 END;
    SELECT @nuls = SUM(CASE WHEN valeur IS NULL THEN 1 ELSE 0 END), @somme = ISNULL(SUM(valeur), 0) FROM @fil;
    EXEC dbo.pr_ann_colonne_vue @c = @c, @a = @a, @n = @nf, @nuls = @nuls, @somme = @somme, @cle = N'valeur_actuelle_titres', @attendu = @att,
         @poste = @p_i34, @rapproche = N'valeur des titres', @lue = @lu5f OUTPUT, @motif = @motif5f OUTPUT;
    IF @fil_actif = 1
        SELECT @lu4 = 0, @motif4 = N'aucune détention de titres enregistrée à l’arrêté : participation détenue selon le registre des actifs, coût de revient frais exclus à remplir',
               @lu5f = 0, @motif5f = N'aucune détention de titres enregistrée à l’arrêté : participation détenue selon le registre des actifs, valeur actuelle comptabilisée à remplir';
    -- le classement : la saisie de la colonne 7 prevaut sur la vue (oracle)
    UPDATE f SET classe = COALESCE(
            CASE LOWER(LTRIM(RTRIM(ISNULL((SELECT TOP (1) s.valeur FROM dbo.saisie_annexe s WHERE s.entite = @entite AND s.arrete = @a AND s.article = @art
                                          AND s.ligne = N'FIL:' + f.fille AND LTRIM(RTRIM(s.colonne)) = N'7' ORDER BY s.id DESC), N''))))
                WHEN N'contrôlée' THEN 'oui' WHEN N'non contrôlée' THEN 'non' END,
            CASE WHEN LOWER(LTRIM(ISNULL(f.controle, N''))) LIKE N'non contr%' OR LOWER(LTRIM(ISNULL(f.controle, N''))) LIKE N'non[_]contr%' THEN 'non'
                 WHEN LOWER(LTRIM(ISNULL(f.controle, N''))) LIKE N'contr%' THEN 'oui' END)
    FROM @fil f;
    UPDATE @fil SET ordre = CASE classe WHEN 'oui' THEN 5.5 WHEN 'non' THEN 6.5 ELSE 6.7 END,
                    groupe = CASE classe WHEN 'oui' THEN 'FIL_CONTROLEES' WHEN 'non' THEN 'FIL_NON_CONTROLEES' ELSE 'FIL_A_CLASSER' END;
    DECLARE @absence BIT = CASE WHEN @nf = 0 AND dbo.fn_ann_balance(@c, @a) = 1 AND @b3 = 0 AND @b4 = 0 THEN 1 ELSE 0 END;
    DECLARE @fil_saisie BIT = CASE WHEN @nf = 0 AND @absence = 0 THEN 1 ELSE 0 END;
    DECLARE @a_classer INT = (SELECT COUNT(*) FROM @fil WHERE classe IS NULL) + @fil_saisie;
    DECLARE @g INT = 1, @gc VARCHAR (3), @gl NVARCHAR (40);
    WHILE @g <= 2
    BEGIN
        SELECT @gc = CASE @g WHEN 1 THEN 'oui' ELSE 'non' END, @gl = CASE @g WHEN 1 THEN N'FIL_CONTROLEES' ELSE N'FIL_NON_CONTROLEES' END;
        IF EXISTS (SELECT 1 FROM @fil WHERE classe = @gc)
            EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @gl, @col = 1, @motif = N'intitulé de groupe', @regle = 'RC1', @fmt = 'texte';
        ELSE IF @a_classer = 0
        BEGIN
            SET @src = CASE WHEN @absence = 1 THEN N'bilan, lignes ' + @n_i3 + N' et ' + @n_i4 + N' nulles : aucune filiale ni participation'
                            ELSE N'aucune filiale classée dans ce groupe, toutes étant classées' END;
            EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = @gl, @col = 1, @source = @src, @nature = 'modele', @obligation = 'SANS', @regle = 'R214_83';
        END;
        ELSE
        BEGIN
            SET @m = N'intitulé de groupe ; aucune filiale classée dans ce groupe, ' + CAST(@a_classer AS NVARCHAR (10)) + N' filiale(s) à classer';
            EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @gl, @col = 1, @motif = @m, @regle = 'R214_83', @fmt = 'texte';
        END;
        SET @g += 1;
    END;
    IF @a_classer > 0
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'FIL_A_CLASSER', @col = 1, @motif = N'intitulé du groupe des filiales à classer', @fmt = 'texte',
             @regle = 'R214_83', @ordre = 6.6, @libelle = N'Filiales ou participations à classer au sens de l''article R214-83 du code monétaire et financier';
    DECLARE @fcodes TABLE (n INT IDENTITY, l NVARCHAR (120));
    IF @fil_saisie = 1
    BEGIN
        SET @l = N'FIL:SAISIE';
        INSERT INTO @fcodes (l) VALUES (@l);
        SET @m = CASE WHEN dbo.fn_ann_balance(@c, @a) = 0 OR @b3 IS NULL OR @b4 IS NULL THEN N'arrêté sans balance' ELSE N'bilan, lignes ' + @n_i3 + N' et ' + @n_i4 + N' de somme non nulle' END
            + N', aucune détention de titres enregistrée à l’arrêté et aucune part de société au registre des actifs : filiales et participations non inventoriées';
        DECLARE @fm2 TABLE (col TINYINT, fmt VARCHAR (10));
        INSERT INTO @fm2 VALUES (1, 'texte'), (2, 'texte'), (3, 'texte'), (4, 'montant'), (5, 'montant');
        DECLARE @f2 VARCHAR (10);
        DECLARE cf2 CURSOR LOCAL FAST_FORWARD FOR SELECT col, fmt FROM @fm2 ORDER BY col;
        OPEN cf2; FETCH NEXT FROM cf2 INTO @col, @f2;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = @m, @fmt = @f2, @libelle = N'Filiale ou participation à inventorier',
                 @ordre = 6.7, @regle = 'RC9', @groupe = 'FIL_A_CLASSER';
            FETCH NEXT FROM cf2 INTO @col, @f2;
        END;
        CLOSE cf2; DEALLOCATE cf2;
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @termes = N'1|336-2|FIL:SAISIE|5;-1|336-2|FIL:SAISIE|4', @regle = 'RC3',
             @libelle = N'Filiale ou participation à inventorier', @ordre = 6.7, @groupe = 'FIL_A_CLASSER';
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 7, @motif = @m, @fmt = 'texte', @libelle = N'Filiale ou participation à inventorier',
             @ordre = 6.7, @regle = 'R214_83', @groupe = 'FIL_A_CLASSER';
    END;
    DECLARE @fille VARCHAR (20), @den NVARCHAR (400), @ctrl NVARCHAR (200), @nimm INT, @cout DECIMAL (38, 12), @val DECIMAL (38, 12), @diff DECIMAL (38, 12),
            @od DECIMAL (19, 6), @gr VARCHAR (40), @base VARCHAR (3);
    DECLARE cfil CURSOR LOCAL FAST_FORWARD FOR
        SELECT fille, denomination, controle, immeubles, cout, valeur, difference, ordre, groupe FROM @fil
        ORDER BY CASE classe WHEN 'oui' THEN 1 WHEN 'non' THEN 2 ELSE 3 END, n;
    OPEN cfil; FETCH NEXT FROM cfil INTO @fille, @den, @ctrl, @nimm, @cout, @val, @diff, @od, @gr;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @l = N'FIL:' + @fille;
        INSERT INTO @fcodes (l) VALUES (@l);
        DECLARE @nimmf INT = (SELECT COUNT(*) FROM dbo.actif WHERE entite_detentrice = @fille);
        -- colonne 1 : nombre et nature des immeubles
        IF @nimmf > 0 AND @nimm IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.actif x LEFT JOIN dbo.ref_compte rc ON rc.compte = x.poste_bilan WHERE x.entite_detentrice = @fille AND rc.libelle IS NULL)
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = N'intitulé du poste au plan absent', @fmt = 'texte',
                     @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
            ELSE
            BEGIN
                SET @tx = dbo.fn_ann_format('nombre', @nimm) + CASE WHEN @nimm = 1 THEN N' immeuble' ELSE N' immeubles' END + N' : '
                    + (SELECT STRING_AGG(lib, N', ') WITHIN GROUP (ORDER BY premier) FROM (
                           SELECT rc.libelle AS lib, MIN(dbo.fn_ann_cle_naturelle(x.code) COLLATE Latin1_General_100_BIN2) AS premier
                           FROM dbo.actif x JOIN dbo.ref_compte rc ON rc.compte = x.poste_bilan WHERE x.entite_detentrice = @fille GROUP BY rc.libelle) t);
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @fmt = 'texte', @texte = @tx,
                     @source = N'registre des actifs, immeubles de la filiale, et intitulé de leur compte au plan de comptes', @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
            END;
        END;
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = N'immeubles de la filiale absents du registre des actifs', @fmt = 'texte',
                 @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
        -- colonne 2 : secteur et adresse
        IF @nimmf > 0 AND NOT EXISTS (SELECT 1 FROM dbo.actif WHERE entite_detentrice = @fille AND (ISNULL(secteur, N'') = N'' OR ISNULL(adresse, N'') = N''))
        BEGIN
            SET @tx = (SELECT STRING_AGG(CAST(secteur + N', ' + adresse AS NVARCHAR (MAX)), N' ; ') WITHIN GROUP (ORDER BY dbo.fn_ann_cle_naturelle(code) COLLATE Latin1_General_100_BIN2)
                       FROM dbo.actif WHERE entite_detentrice = @fille);
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @etat = 'LU', @fmt = 'texte', @texte = @tx,
                 @source = N'registre des actifs, secteur et adresse des immeubles de la filiale', @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
        END;
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @motif = N'secteur ou adresse d’un immeuble de la filiale absent du registre des actifs',
                 @fmt = 'texte', @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
        -- colonne 3 : dates d'acquisition des parts, a defaut des immeubles
        DECLARE @dates TABLE (d DATE PRIMARY KEY);
        DELETE @dates;
        IF EXISTS (SELECT 1 FROM dbo.actif WHERE entite_detentrice = @entite AND entite_liee = @fille AND LEFT(ISNULL(poste_bilan, ''), 2) = '25')
            INSERT INTO @dates SELECT DISTINCT date_acquisition FROM dbo.actif
            WHERE entite_detentrice = @entite AND entite_liee = @fille AND LEFT(ISNULL(poste_bilan, ''), 2) = '25' AND date_acquisition IS NOT NULL;
        ELSE
            INSERT INTO @dates SELECT DISTINCT date_acquisition FROM dbo.actif WHERE entite_detentrice = @fille AND date_acquisition IS NOT NULL;
        IF EXISTS (SELECT 1 FROM @dates)
        BEGIN
            SET @tx = (SELECT STRING_AGG(dbo.fn_ann_date_fr(CONVERT(NVARCHAR (10), d, 23)), N' ; ') WITHIN GROUP (ORDER BY d) FROM @dates);
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @etat = 'LU', @fmt = 'texte', @texte = @tx,
                 @source = N'registre des actifs, date d’acquisition des parts, à défaut celle des immeubles, dans l’ordre des dates', @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
        END;
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @motif = N'dates d’acquisition absentes du registre des actifs', @fmt = 'texte',
                 @libelle = @den, @ordre = @od, @regle = 'RC9', @groupe = @gr;
        -- colonnes 4 et 5 : cout et valeur (regle RV)
        IF @lu4 = 0
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @motif = @motif4, @libelle = @den, @ordre = @od, @regle = 'RV', @groupe = @gr;
        ELSE
            EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @v = @cout, @source = N'inventaire des participations à l’arrêté, coût de revient des titres frais exclus',
                 @libelle = @den, @ordre = @od, @regle = 'RC3', @groupe = @gr;
        IF @lu5f = 0
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @motif = @motif5f, @libelle = @den, @ordre = @od, @regle = 'RV', @groupe = @gr;
        ELSE
            EXEC dbo.pr_ann_lu_ou_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 5, @v = @val, @source = N'inventaire des participations à l’arrêté, valeur actuelle des titres',
                 @libelle = @den, @ordre = @od, @regle = 'RC3', @groupe = @gr;
        SET @t = N'1|336-2|' + @l + N'|5;-1|336-2|' + @l + N'|4';
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 6, @termes = @t, @regle = 'RC3', @libelle = @den, @ordre = @od, @groupe = @gr;
        -- colonne 7 : le classement, saisissable
        SET @base = CASE WHEN LOWER(LTRIM(ISNULL(@ctrl, N''))) LIKE N'non contr%' OR LOWER(LTRIM(ISNULL(@ctrl, N''))) LIKE N'non[_]contr%' THEN 'non'
                         WHEN LOWER(LTRIM(ISNULL(@ctrl, N''))) LIKE N'contr%' THEN 'oui' END;
        DECLARE @s7_id INT = NULL, @s7_val NVARCHAR (4000) = NULL;
        SELECT TOP (1) @s7_id = id, @s7_val = LOWER(LTRIM(RTRIM(ISNULL(valeur, N'')))) FROM dbo.saisie_annexe
        WHERE entite = @entite AND arrete = @a AND article = @art AND ligne = @l AND LTRIM(RTRIM(colonne)) = N'7' ORDER BY id DESC;
        DECLARE @et7 VARCHAR (12), @tx7 NVARCHAR (2000), @src7 NVARCHAR (400), @mo7 NVARCHAR (400);
        IF @base IS NULL
            SELECT @et7 = 'A_REMPLIR', @tx7 = NULL, @src7 = N'', @mo7 = N'classement au sens de l’article R. 214-83 du CMF absent de la base';
        ELSE
            SELECT @et7 = 'LU', @tx7 = CASE @base WHEN 'oui' THEN N'contrôlée' ELSE N'non contrôlée' END,
                   @src7 = N'classement de la filiale au sens de l’article R. 214-83 du CMF, enregistré au dossier', @mo7 = NULL;
        DECLARE @sid INT = CASE WHEN @s7_id IS NOT NULL AND @s7_val IN (N'contrôlée', N'non contrôlée') THEN @s7_id ELSE 0 END;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 7, @etat = @et7, @fmt = 'texte', @texte = @tx7, @source = @src7, @motif = @mo7,
             @saisie_id = @sid, @libelle = @den, @ordre = @od, @regle = 'R214_83', @groupe = @gr;
        IF @s7_id IS NOT NULL AND @sid = 0
            UPDATE dbo.annexe_w_cel SET saisie_ecartee = N'écartée : classement attendu « contrôlée » ou « non contrôlée » (refus 50647)'
            WHERE calcul_id = @c AND arrete = @a AND article = @art AND ligne = @l AND colonne = 7;
        DECLARE @vv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @l, 6);
        IF @vv IS NOT NULL AND @diff IS NOT NULL
        BEGIN
            DECLARE @ed DECIMAL (38, 12) = @vv - @diff;
            EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S336_2_DIFFERENCE', @cle = @l, @ecart = @ed;
        END;
        FETCH NEXT FROM cfil INTO @fille, @den, @ctrl, @nimm, @cout, @val, @diff, @od, @gr;
    END;
    CLOSE cfil; DEALLOCATE cfil;
    EXEC dbo.pr_ann_ligne_retiree @c = @c, @a = @a, @art = @art, @ligne = N'FIL_NATURE', @regle = 'RC9', @motif = N'la donnée se saisit filiale par filiale, sur la ligne de chaque filiale';
    EXEC dbo.pr_ann_ligne_retiree @c = @c, @a = @a, @art = @art, @ligne = N'FIL_SECTEUR', @regle = 'RC9', @motif = N'la donnée se saisit filiale par filiale, sur la ligne de chaque filiale';
    EXEC dbo.pr_ann_ligne_retiree @c = @c, @a = @a, @art = @art, @ligne = N'FIL_DATE', @regle = 'RC9', @motif = N'la donnée se saisit filiale par filiale, sur la ligne de chaque filiale';

    -- ------------------------------------------------------------ AUTRES ACTIFS A CARACTERE IMMOBILIER
    -- revision 12 : chaque poste du bilan (A_IMMO_2, 5, 6, 7, 8) a au moins une ligne de son groupe : ses actifs au compte
    -- auxiliaire, sinon AUT:NEANT:<poste> quand la ligne du bilan est nulle, sinon AUT:SAISIE:<poste> ; ordre 13,1 a 13,5
    DECLARE @postes TABLE (n INT, i_poste INT, poste VARCHAR (20), cpt VARCHAR (4), compte_de VARCHAR (4));
    INSERT INTO @postes VALUES (1, 1, 'A_IMMO_2', '243', '274'), (2, 2, 'A_IMMO_5', '256', '275'), (3, 3, 'A_IMMO_6', '258', '275'), (4, 4, 'A_IMMO_7', '245', NULL),
                               (5, 5, 'A_IMMO_8', '265', '276'), (6, 5, 'A_IMMO_8', '266', '276');
    DECLARE @acodes TABLE (n INT IDENTITY, l NVARCHAR (120));
    DECLARE @poste VARCHAR (20), @cpt VARCHAR (4), @cde VARCHAR (4), @aux NVARCHAR (40), @s DECIMAL (38, 12), @ip INT, @op DECIMAL (19, 6), @n_poste INT;
    DECLARE cpo CURSOR LOCAL FAST_FORWARD FOR SELECT DISTINCT i_poste, poste FROM @postes ORDER BY i_poste;
    OPEN cpo; FETCH NEXT FROM cpo INTO @ip, @poste;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @op = 13 + @ip / 10.0;
        SET @n_poste = (SELECT COUNT(*) FROM @acodes);
        DECLARE cp CURSOR LOCAL FAST_FORWARD FOR SELECT cpt, compte_de FROM @postes WHERE i_poste = @ip ORDER BY n;
        OPEN cp; FETCH NEXT FROM cp INTO @cpt, @cde;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE ca CURSOR LOCAL FAST_FORWARD FOR
                SELECT comp_aux_num, SUM(solde) FROM dbo.annexe_w_sol WHERE calcul_id = @c AND arrete = @a AND compte_num LIKE @cpt + '%'
                GROUP BY comp_aux_num HAVING SUM(solde) <> 0 ORDER BY dbo.fn_ann_cle_naturelle(ISNULL(comp_aux_num, N'')) COLLATE Latin1_General_100_BIN2;
            OPEN ca; FETCH NEXT FROM ca INTO @aux, @s;
            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @l = N'AUT:' + @cpt + N':' + ISNULL(@aux, N'');
                INSERT INTO @acodes (l) VALUES (@l);
                DECLARE @lc NVARCHAR (400) = ISNULL((SELECT libelle FROM dbo.ref_compte WHERE compte = @cpt), @cpt);
                DECLARE @src1 NVARCHAR (200) = CASE WHEN ISNULL(@aux, N'') <> N'' THEN N'intitulé du compte au plan de comptes et dénomination de la société du compte auxiliaire' ELSE N'intitulé du compte au plan de comptes' END;
                SET @tx = CASE WHEN ISNULL(@aux, N'') <> N'' THEN @lc + N' : ' + ISNULL((SELECT denomination FROM dbo.ref_entite WHERE code = @aux), @aux) ELSE @lc END;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @fmt = 'texte', @texte = @tx, @source = @src1,
                     @regle = 'RC3', @ordre = @op, @libelle = @tx, @groupe = @poste;
                SET @src = CASE WHEN ISNULL(@aux, N'') <> N'' THEN N'solde du ' + @cpt + N' au compte auxiliaire de ' + dbo.fn_ann_nom_entite(@aux) ELSE N'solde du ' + @cpt + N', sans compte auxiliaire' END;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @etat = 'LU', @valeur = @s, @source = @src, @regle = 'RC3', @ordre = @op, @libelle = @tx, @groupe = @poste;
                DECLARE @sde DECIMAL (38, 12) = CASE WHEN @cde IS NOT NULL THEN dbo.fn_ann_S(@c, @a, @cde, '', N'*', 0) ELSE 0 END;
                DECLARE @o2 NVARCHAR (200) = N'336-2|' + @l + N'|2';
                IF @cde IS NULL OR @sde = 0
                BEGIN
                    SET @src = N'nominal ; ' + ISNULL(@cde, N'aucune différence') + N' nul';
                    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @etat = 'CALCULE', @valeur = @s, @source = @src, @ops = @o2,
                         @regle = 'RC3', @ordre = @op, @libelle = @tx, @groupe = @poste;
                END;
                ELSE IF @cde = '275' OR EXISTS (SELECT 1 FROM dbo.annexe_w_sol WHERE calcul_id = @c AND arrete = @a AND comp_aux_num IS NULL AND compte_num LIKE @cde + '%' AND solde <> 0)
                BEGIN
                    SET @m = N'différence d’estimation du ' + @cde + N' non portée au compte auxiliaire';
                    EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @motif = @m, @regle = 'RC3', @ordre = @op, @libelle = @tx, @groupe = @poste;
                END;
                ELSE
                BEGIN
                    SET @v = @s + dbo.fn_ann_S(@c, @a, @cde, '', ISNULL(@aux, N''), 0);
                    SET @src = N'nominal + ' + @cde + N' au compte auxiliaire';
                    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @etat = 'CALCULE', @valeur = @v, @source = @src, @ops = @o2,
                         @regle = 'RC3', @ordre = @op, @libelle = @tx, @groupe = @poste;
                END;
                EXEC dbo.pr_ann_pct @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @n_art = @art, @n_ligne = @l, @n_col = 3, @regle = 'RC3', @ordre = @op, @libelle = @tx, @groupe = @poste;
                FETCH NEXT FROM ca INTO @aux, @s;
            END;
            CLOSE ca; DEALLOCATE ca;
            FETCH NEXT FROM cp INTO @cpt, @cde;
        END;
        CLOSE cp; DEALLOCATE cp;
        IF (SELECT COUNT(*) FROM @acodes) = @n_poste
        BEGIN
            DECLARE @bp DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, @poste, 1);
            IF dbo.fn_ann_balance(@c, @a) = 1 AND @bp = 0
            BEGIN
                SET @l = N'AUT:NEANT:' + @poste;
                SET @src = N'bilan, poste ' + dbo.fn_ann_nom_etat(@poste) + N' nul';
                EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @source = @src, @libelle = N'Néant', @regle = 'RC3', @ordre = @op, @groupe = @poste;
                SET @m = N'aucun actif au poste ' + dbo.fn_ann_nom_etat(@poste);
                SET @col = 2;
                WHILE @col <= 4
                BEGIN
                    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = @m, @libelle = N'Néant', @regle = 'RC3', @ordre = @op, @groupe = @poste;
                    SET @col += 1;
                END;
            END;
            ELSE
            BEGIN
                SET @l = N'AUT:SAISIE:' + @poste;
                INSERT INTO @acodes (l) VALUES (@l);
                SET @m = CASE WHEN dbo.fn_ann_balance(@c, @a) = 0 THEN N'arrêté sans balance : l’absence d’actif au poste ' + dbo.fn_ann_nom_etat(@poste) + N' n’est pas établie'
                              WHEN @bp IS NULL THEN N'ligne ' + dbo.fn_ann_nom_etat(@poste) + N' du bilan absente : l’absence d’actif au poste n’est pas établie'
                              ELSE N'poste ' + dbo.fn_ann_nom_etat(@poste) + N' du bilan non nul sans solde au compte auxiliaire de ses comptes' END;
                DECLARE @la NVARCHAR (500) = N'Autre actif à caractère immobilier à inventorier';
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @motif = @m, @fmt = 'texte', @libelle = @la, @regle = 'RC3', @ordre = @op, @groupe = @poste;
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @motif = @m, @fmt = 'montant', @libelle = @la, @regle = 'RC3', @ordre = @op, @groupe = @poste;
                EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 3, @motif = @m, @fmt = 'montant', @libelle = @la, @regle = 'RC3', @ordre = @op, @groupe = @poste;
                EXEC dbo.pr_ann_pct @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 4, @n_art = @art, @n_ligne = @l, @n_col = 3, @regle = 'RC3', @libelle = @la, @ordre = @op, @groupe = @poste;
            END;
        END;
        FETCH NEXT FROM cpo INTO @ip, @poste;
    END;
    CLOSE cpo; DEALLOCATE cpo;
    DECLARE @nb_bs INT, @sum_bs DECIMAL (38, 12);
    SELECT @nb_bs = COUNT(dbo.fn_ann_E(@c, @a, p.poste, 1)), @sum_bs = SUM(dbo.fn_ann_E(@c, @a, p.poste, 1))
    FROM (VALUES ('A_IMMO_2'), ('A_IMMO_5'), ('A_IMMO_6'), ('A_IMMO_7'), ('A_IMMO_8')) p (poste);
    -- controles
    DECLARE @tp DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'IMM_TOTAL', 5), @tv DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'IMM_TOTAL', 6), @e DECIMAL (38, 12);
    IF @tp IS NOT NULL AND @couts IS NOT NULL AND @ni > 0
    BEGIN
        SET @e = @tp - @couts;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C336_2_BILAN', @cle = N'prix de revient des immeubles', @ecart = @e;
    END;
    DECLARE @b1 DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'A_IMMO_1', 1);
    IF @tv IS NOT NULL AND @b1 IS NOT NULL AND @ni > 0
    BEGIN
        SET @e = @tv - @b1;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C336_2_BILAN', @cle = N'valeur des immeubles', @ecart = @e;
    END;
    DECLARE @nfc INT = (SELECT COUNT(*) FROM @fcodes), @nfv INT, @sfv DECIMAL (38, 12);
    SELECT @nfv = COUNT(dbo.fn_ann_val(@c, @a, @art, l, 5)), @sfv = SUM(dbo.fn_ann_val(@c, @a, @art, l, 5)) FROM @fcodes;
    IF @nfc > 0 AND @nfv = @nfc AND @b3 IS NOT NULL AND @b4 IS NOT NULL
    BEGIN
        SET @e = @sfv - (@b3 + @b4);
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C336_2_BILAN', @cle = N'valeur des titres', @ecart = @e;
    END;
    DECLARE @nac INT = (SELECT COUNT(*) FROM @acodes), @nav INT, @sav DECIMAL (38, 12);
    SELECT @nav = COUNT(dbo.fn_ann_val(@c, @a, @art, l, 3)), @sav = SUM(dbo.fn_ann_val(@c, @a, @art, l, 3)) FROM @acodes;
    IF @nac > 0 AND @nav = @nac AND @nb_bs = 5
    BEGIN
        SET @e = @sav - @sum_bs;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'C336_2_BILAN', @cle = N'autres actifs', @ecart = @e;
    END;
    DECLARE @anr DECIMAL (38, 12) = dbo.fn_ann_num(@c, 'ANR', @a), @pcp DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, 'P_CP', 1);
    IF @anr IS NOT NULL AND @pcp IS NOT NULL
    BEGIN
        SET @e = @anr - @pcp;
        EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S336_2_ACTIF_NET', @cle = N'actif net', @ecart = @e;
    END;
END;

GO

