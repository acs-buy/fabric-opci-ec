
-- Montant par part sur des cellules de la table (oracle, par_part) : somme des termes divisee par les parts de la
-- colonne, plus des montants deja unitaires. @termes : « signe|article|ligne|colonne » ; @unitaires : « article|ligne|colonne ».
CREATE   PROCEDURE dbo.pr_ann_par_part @c INT, @a VARCHAR (20), @code VARCHAR (24), @k INT, @termes NVARCHAR (MAX), @unitaires NVARCHAR (MAX),
                                          @formule NVARCHAR (MAX), @source NVARCHAR (MAX)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '332-1';
    DECLARE @t TABLE (n INT, sg INT, art VARCHAR (10), ligne NVARCHAR (120), col TINYINT, unitaire BIT);
    INSERT INTO @t SELECT x.ordinal, CAST(PARSENAME(REPLACE(x.value, N'|', N'.'), 4) AS INT), PARSENAME(REPLACE(x.value, N'|', N'.'), 3),
                          PARSENAME(REPLACE(x.value, N'|', N'.'), 2), CAST(PARSENAME(REPLACE(x.value, N'|', N'.'), 1) AS TINYINT), 0
    FROM STRING_SPLIT(@termes, N';', 1) x WHERE x.value <> N'';
    INSERT INTO @t SELECT 100 + x.ordinal, 1, PARSENAME(REPLACE(x.value, N'|', N'.'), 3), PARSENAME(REPLACE(x.value, N'|', N'.'), 2),
                          CAST(PARSENAME(REPLACE(x.value, N'|', N'.'), 1) AS TINYINT), 1
    FROM STRING_SPLIT(ISNULL(@unitaires, N''), N';', 1) x WHERE x.value <> N'';
    DECLARE @nb_l NVARCHAR (120) = N'NB_PARTS', @nb_c TINYINT = @k;
    DECLARE @ops NVARCHAR (MAX) = (SELECT STRING_AGG(art + N'|' + ligne + N'|' + CAST(col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @t WHERE unitaire = 0)
        + N';332-1|NB_PARTS|' + CAST(@k AS NVARCHAR (2))
        + ISNULL(N';' + (SELECT STRING_AGG(art + N'|' + ligne + N'|' + CAST(col AS NVARCHAR (2)), N';') WITHIN GROUP (ORDER BY n) FROM @t WHERE unitaire = 1), N'');
    DECLARE @sid INT = dbo.fn_ann_saisie_annee(@c, @a, @code, dbo.fn_ann_annee(@c, @a) - (@k - 1));
    DECLARE @nb_connue BIT = dbo.fn_ann_connue(@c, @a, @art, @nb_l, @nb_c), @nb DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, @nb_l, @nb_c);
    IF @nb_connue = 1 AND @nb = 0
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @motif = N'aucune part en circulation', @fmt = 'unitaire', @regle = 'A332_1',
             @nature = 'modele', @obligation = 'SANS', @ops = @ops, @formule = @formule, @saisie_id = @sid;
        RETURN;
    END;
    DECLARE @n INT = (SELECT COUNT(*) FROM @t) + 1, @nconnues INT, @attente INT;
    SELECT @nconnues = SUM(CASE WHEN w.etat IN ('LU', 'CALCULE', 'SAISI') THEN 1 ELSE 0 END), @attente = SUM(CASE WHEN w.etat IN ('A_REMPLIR', 'EN_ATTENTE') THEN 1 ELSE 0 END)
    FROM (SELECT art, ligne, col FROM @t UNION ALL SELECT '332-1', @nb_l, @nb_c) t
    LEFT JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a AND w.article = t.art AND w.ligne = t.ligne AND w.colonne = t.col;
    IF @nconnues = @n
    BEGIN
        DECLARE @tot DECIMAL (38, 12) = (SELECT SUM(t.sg * w.valeur) FROM @t t JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a AND w.article = t.art
                                         AND w.ligne = t.ligne AND w.colonne = t.col WHERE t.unitaire = 0);
        DECLARE @ac DECIMAL (38, 12) = ISNULL((SELECT SUM(w.valeur) FROM @t t JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a AND w.article = t.art
                                         AND w.ligne = t.ligne AND w.colonne = t.col WHERE t.unitaire = 1), 0);
        DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_div(ISNULL(@tot, 0), @nb) + @ac;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @etat = 'CALCULE', @valeur = @v, @source = @source, @fmt = 'unitaire',
             @regle = 'A332_1', @nature = 'calcul', @obligation = 'SANS', @ops = @ops, @formule = @formule, @saisie_id = @sid;
        RETURN;
    END;
    IF @attente > 0
    BEGIN
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @etat = 'EN_ATTENTE', @motif = N'affectation, acomptes ou parts à remplir',
             @fmt = 'unitaire', @regle = 'A332_1', @nature = 'calcul', @obligation = 'SANS', @ops = @ops, @formule = @formule, @saisie_id = @sid;
        RETURN;
    END;
    EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @code, @col = @k, @motif = N'opérande sans objet', @fmt = 'unitaire', @regle = 'A332_1',
         @nature = 'modele', @obligation = 'SANS', @ops = @ops, @formule = @formule, @saisie_id = @sid;
END;

GO

