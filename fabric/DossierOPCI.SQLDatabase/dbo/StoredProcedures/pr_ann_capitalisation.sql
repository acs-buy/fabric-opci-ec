
-- La capitalisation par part de l'exercice @y, colonne @k (oracle, capitalisation).
CREATE   PROCEDURE dbo.pr_ann_capitalisation @c INT, @a VARCHAR (20), @k INT, @y INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '332-1', @kc NVARCHAR (2) = CAST(@k AS NVARCHAR (2));
    IF @k <= 2
    BEGIN
        DECLARE @t NVARCHAR (200) = N'1|335-12|I_A_3|' + @kc + N';1|335-12|II_A_3|' + @kc;
        DECLARE @f NVARCHAR (200) = N'(335-12 I_A_3[' + @kc + N'] + II_A_3[' + @kc + N']) / NB_PARTS[' + @kc + N']';
        EXEC dbo.pr_ann_par_part @c = @c, @a = @a, @code = 'CAPITALISATION', @k = @k, @termes = @t, @unitaires = NULL, @formule = @f,
             @source = N'sommes capitalisées (335-12) par part';
        RETURN;
    END;
    DECLARE @sid INT = dbo.fn_ann_saisie_annee(@c, @a, N'CAPITALISATION', @y);
    DECLARE @a_y1 VARCHAR (20) = dbo.fn_ann_annuel_de(@c, @y + 1, dbo.fn_ann_date(@c, @a));
    DECLARE @t_existe BIT = CASE WHEN @a_y1 IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a_y1) THEN 1 ELSE 0 END;
    IF @t_existe = 0 OR dbo.fn_ann_connue(@c, @a_y1, '335-12', N'I_A_3', 2) = 0 OR dbo.fn_ann_connue(@c, @a_y1, '335-12', N'II_A_3', 2) = 0
    BEGIN
        DECLARE @m NVARCHAR (400) = N'capitalisation de l’exercice ' + CAST(@y AS NVARCHAR (4)) + N' non établie à l’arrêté '
            + ISNULL(N'du ' + CONVERT(NVARCHAR (10), dbo.fn_ann_date(@c, @a_y1), 103), N'de l’exercice ' + CAST(@y + 1 AS NVARCHAR (4))) + N' (335-12, colonne Exercice N-1)';
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = N'CAPITALISATION', @col = @k, @motif = @m, @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
        RETURN;
    END;
    DECLARE @n_connue BIT = dbo.fn_ann_connue(@c, @a, @art, N'NB_PARTS', @k), @n DECIMAL (38, 12) = dbo.fn_ann_val(@c, @a, @art, N'NB_PARTS', @k);
    IF @n_connue = 1 AND @n = 0
    BEGIN
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = N'CAPITALISATION', @col = @k, @motif = N'aucune part en circulation', @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
        RETURN;
    END;
    IF @n_connue = 0
    BEGIN
        DECLARE @o NVARCHAR (100) = N'332-1|NB_PARTS|' + @kc;
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'CAPITALISATION', @col = @k, @etat = 'EN_ATTENTE', @nature = 'calcul', @obligation = 'SANS', @ops = @o,
             @motif = N'parts à remplir', @fmt = 'unitaire', @regle = 'A332_1', @saisie_id = @sid;
        RETURN;
    END;
    DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_div(dbo.fn_ann_val(@c, @a_y1, '335-12', N'I_A_3', 2) + dbo.fn_ann_val(@c, @a_y1, '335-12', N'II_A_3', 2), @n);
    DECLARE @src NVARCHAR (MAX) = N'annexe de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @a_y1) + N', 335-12, ' + dbo.fn_ann_nom_ligne(@c, @a_y1, '335-12', N'I_A_3') + N' et '
        + dbo.fn_ann_nom_ligne(@c, @a_y1, '335-12', N'II_A_3') + N', colonne 2, par part de l’exercice ' + CAST(@y AS NVARCHAR (4));
    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = N'CAPITALISATION', @col = @k, @etat = 'CALCULE', @valeur = @v, @source = @src, @fmt = 'unitaire',
         @regle = 'A332_1', @saisie_id = @sid;
END;

GO

