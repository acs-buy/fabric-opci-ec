
-- Regle M (oracle, regle_m) : augmentations et diminutions lues au registre quand il explique la variation du cout,
-- sinon a remplir ; une saisie de l'une donne l'autre par la variation du cout. @cout_n et @cout_p : le cout impose
-- par l'appelant (334-6), sinon le cout des comptes. @registre = 0 quand aucune nature du registre ne porte ces flux ;
-- @sans_registre est alors le motif, « %s » valant la variation.
CREATE   PROCEDURE dbo.pr_ann_regle_m
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col_aug TINYINT, @col_dim TINYINT,
    @comptes VARCHAR (400), @exclues VARCHAR (400), @code_filtre VARCHAR (40) = NULL, @registre BIT = 1,
    @sans_registre NVARCHAR (400) = NULL, @cout_impose BIT = 0, @cout_n DECIMAL (38, 12) = NULL, @cout_p DECIMAL (38, 12) = NULL,
    @regle VARCHAR (12) = 'RC7', @libelle NVARCHAR (500) = NULL, @ordre DECIMAL (19, 6) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @P VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @cn DECIMAL (38, 12) = CASE WHEN @cout_impose = 1 THEN @cout_n ELSE dbo.fn_ann_Sl(@c, @a, @comptes, @exclues) END;
    DECLARE @cp DECIMAL (38, 12) = CASE WHEN @P IS NULL THEN NULL WHEN @cout_impose = 1 THEN @cout_p ELSE dbo.fn_ann_Sl(@c, @P, @comptes, @exclues) END;
    DECLARE @dC DECIMAL (38, 12) = @cn - @cp;
    DECLARE @sa BIT = 0, @sdm BIT = 0, @m NVARCHAR (MAX);
    IF EXISTS (SELECT 1 FROM dbo.saisie_annexe WHERE entite = @entite AND arrete = @a AND article = @art AND ligne = @ligne AND LTRIM(RTRIM(colonne)) = CAST(@col_aug AS NVARCHAR (4))) SET @sa = 1;
    IF EXISTS (SELECT 1 FROM dbo.saisie_annexe WHERE entite = @entite AND arrete = @a AND article = @art AND ligne = @ligne AND LTRIM(RTRIM(colonne)) = CAST(@col_dim AS NVARCHAR (4))) SET @sdm = 1;
    IF @sa = 0 AND @sdm = 0
    BEGIN
        IF @dC IS NULL SET @m = N'exercice N-1 ou N sans balance';
        ELSE IF @registre = 1
        BEGIN
            DECLARE @e DECIMAL (38, 12), @sd DECIMAL (38, 12), @n INT;
            SELECT @e = e, @sd = sd, @n = n FROM dbo.fn_ann_flux(@c, @a, @comptes, @exclues, @code_filtre);
            IF @n > 0 AND @e - @sd = @dC
            BEGIN
                DECLARE @src NVARCHAR (MAX) = N'registre des mouvements d’actifs : ' + CAST(@n AS NVARCHAR (10)) + N' mouvement(s) de l’exercice ; variation du coût ' + dbo.fn_ann_format('montant', @dC);
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col_aug, @etat = 'LU', @valeur = @e, @source = @src, @regle = @regle, @libelle = @libelle, @ordre = @ordre;
                EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col_dim, @etat = 'LU', @valeur = @sd, @source = @src, @regle = @regle, @libelle = @libelle, @ordre = @ordre;
                RETURN;
            END;
            SET @m = CASE WHEN @n = 0
                THEN N'le registre des mouvements d’actifs ne porte aucun mouvement de la ligne sur l’exercice : la base n’établit que la variation nette du coût, ' + dbo.fn_ann_format('montant', @dC)
                ELSE N'mouvements du registre (' + dbo.fn_ann_format('montant', @e) + N' - ' + dbo.fn_ann_format('montant', @sd) + N') qui n’expliquent pas la variation du coût, ' + dbo.fn_ann_format('montant', @dC) END;
        END;
        ELSE SET @m = REPLACE(@sans_registre, N'%s', dbo.fn_ann_format('montant', @dC));
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col_aug, @motif = @m, @regle = @regle, @libelle = @libelle, @ordre = @ordre;
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col_dim, @motif = @m, @regle = @regle, @libelle = @libelle, @ordre = @ordre;
        RETURN;
    END;
    IF @dC IS NULL OR (@sa = 1 AND @sdm = 1)
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col_aug, @motif = N'exercice N-1 ou N sans balance', @regle = @regle, @libelle = @libelle, @ordre = @ordre;
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col_dim, @motif = N'exercice N-1 ou N sans balance', @regle = @regle, @libelle = @libelle, @ordre = @ordre;
        RETURN;
    END;
    DECLARE @saisi TINYINT = CASE WHEN @sa = 1 THEN @col_aug ELSE @col_dim END, @autre TINYINT = CASE WHEN @sa = 1 THEN @col_dim ELSE @col_aug END,
            @sens INT = CASE WHEN @sa = 1 THEN -1 ELSE 1 END;
    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @saisi, @etat = 'A_REMPLIR', @motif = N'flux saisi', @regle = @regle, @libelle = @libelle, @ordre = @ordre;
    DECLARE @v DECIMAL (38, 12) = (SELECT valeur + @sens * @dC FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a AND article = @art
                                   AND ligne = @ligne AND colonne = @saisi AND etat = 'SAISI' AND valeur IS NOT NULL);
    IF @v IS NULL OR @v < 0
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @autre, @motif = N'déduction de la saisie impossible', @regle = @regle, @libelle = @libelle, @ordre = @ordre;
    ELSE
    BEGIN
        DECLARE @s2 NVARCHAR (200) = CASE WHEN @sens < 0 THEN N'augmentations saisies, moins la variation du coût' ELSE N'diminutions saisies, plus la variation du coût' END;
        DECLARE @ops NVARCHAR (200) = @art + N'|' + @ligne + N'|' + CAST(@saisi AS NVARCHAR (4));
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @autre, @etat = 'CALCULE', @valeur = @v, @source = @s2, @ops = @ops, @regle = @regle, @libelle = @libelle, @ordre = @ordre;
    END;
END;

GO

