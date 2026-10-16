
-- Regle N (oracle, Table.copie_n1) : la colonne Exercice N-1 est la colonne Exercice N de la meme ligne (ou de @de_*)
-- dans la table de l'arrete N-1, cellule de source ; non etablie a N-1 ou sans table N-1, a remplir a N. @etat_n1 : le
-- code de la ligne d'etat qu'une cellule d'etat reproduit, lue en colonne Exercice N-1 quand N-1 ne l'etablit pas.
CREATE   PROCEDURE dbo.pr_ann_copie_n1
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT = 2,
    @de_art VARCHAR (10) = NULL, @de_ligne NVARCHAR (120) = NULL, @de_col TINYINT = NULL, @etat_n1 VARCHAR (40) = NULL,
    @regle VARCHAR (12) = 'RN', @nature VARCHAR (8) = 'source', @obligation VARCHAR (14) = 'IMPOSEE',
    @fmt VARCHAR (10) = NULL, @libelle NVARCHAR (500) = NULL, @ordre DECIMAL (19, 6) = NULL, @signe VARCHAR (4) = NULL,
    @groupe VARCHAR (40) = NULL, @saisie_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @nature NOT IN ('texte', 'source', 'etat') SET @nature = 'source';
    IF @obligation = 'SANS' SET @obligation = 'IMPOSEE';
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @s_art VARCHAR (10) = ISNULL(@de_art, @art), @s_ligne NVARCHAR (120) = ISNULL(@de_ligne, @ligne), @s_col TINYINT = ISNULL(@de_col, 1);
    DECLARE @p_etat VARCHAR (12), @p_val DECIMAL (38, 12), @p_tv NVARCHAR (2000), @p_fmt VARCHAR (10), @p_existe BIT = 0;
    SELECT @p_etat = etat, @p_val = valeur, @p_tv = texte_valeur, @p_fmt = fmt, @p_existe = 1 FROM dbo.annexe_w_cel
    WHERE calcul_id = @c AND arrete = @n1 AND article = @s_art AND ligne = @s_ligne AND colonne = @s_col;
    IF @etat_n1 IS NOT NULL AND (@p_existe = 0 OR @p_etat IN ('A_REMPLIR', 'EN_ATTENTE'))
    BEGIN
        DECLARE @v DECIMAL (38, 12) = dbo.fn_ann_E(@c, @a, @etat_n1, 2);
        IF @v IS NOT NULL
        BEGIN
            DECLARE @src_e NVARCHAR (MAX) = CASE WHEN @etat_n1 LIKE 'R[_]%' THEN N'compte de résultat' ELSE N'bilan' END
                + N', ligne ' + dbo.fn_ann_nom_etat(@etat_n1) + N', colonne Exercice N-1';
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'LU', @valeur = @v,
                 @source = @src_e, @regle = 'RC10', @nature = 'etat', @obligation = @obligation, @fmt = 'montant',
                 @libelle = @libelle, @ordre = @ordre, @signe = @signe, @groupe = @groupe, @saisie_id = @saisie_id;
            RETURN;
        END;
    END;
    IF @p_existe = 0
    BEGIN
        DECLARE @m NVARCHAR (MAX) = CASE WHEN @n1 IS NULL
            THEN N'1er exercice suivi, aucun arrêté annuel antérieur au dossier : le comparatif se saisit, avec un motif'
            ELSE N'exercice N-1 absent de la base : aucune annexe calculée à l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @n1) END;
        DECLARE @f0 VARCHAR (10) = ISNULL(@fmt, 'montant');
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @motif = @m, @regle = @regle,
             @nature = @nature, @obligation = @obligation, @fmt = @f0, @libelle = @libelle, @ordre = @ordre, @signe = @signe,
             @groupe = @groupe, @saisie_id = @saisie_id;
        RETURN;
    END;
    SET @fmt = ISNULL(@fmt, @p_fmt);
    DECLARE @source NVARCHAR (MAX) = N'annexe de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @n1) + N', ' + dbo.fn_ann_nom_ligne(@c, @n1, @s_art, @s_ligne) + N', colonne ' + CAST(@s_col AS NVARCHAR (4)) + N' (' + dbo.fn_ann_texte_etat(@p_etat) + N')';
    IF @p_etat IN ('LU', 'CALCULE', 'SAISI')
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'LU', @valeur = @p_val,
             @texte = @p_tv, @source = @source, @regle = @regle, @nature = @nature, @obligation = @obligation, @fmt = @fmt,
             @libelle = @libelle, @ordre = @ordre, @signe = @signe, @groupe = @groupe, @saisie_id = @saisie_id;
    ELSE IF @p_etat IN ('A_REMPLIR', 'EN_ATTENTE')
    BEGIN
        DECLARE @m2 NVARCHAR (MAX) = N'non établie à l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @n1) + N' (' + CASE WHEN @p_etat = 'A_REMPLIR' THEN N'à remplir' ELSE N'calcul en attente' END
            + N') : à remplir à cet arrêté ou à saisir ici';
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @motif = @m2, @source = @source,
             @regle = @regle, @nature = @nature, @obligation = @obligation, @fmt = @fmt, @libelle = @libelle, @ordre = @ordre,
             @signe = @signe, @groupe = @groupe, @saisie_id = @saisie_id;
    END;
    ELSE
        EXEC dbo.pr_ann_so @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @motif = N'sans objet à l’arrêté N-1',
             @regle = @regle, @fmt = @fmt, @libelle = @libelle, @ordre = @ordre, @signe = @signe, @groupe = @groupe,
             @saisie_id = @saisie_id;
END;

GO

