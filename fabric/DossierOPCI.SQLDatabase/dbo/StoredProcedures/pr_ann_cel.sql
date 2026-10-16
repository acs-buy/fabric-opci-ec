
-- ------------------------------------------------------------------------------------------------- la cellule
-- Cree la cellule (oracle, Table.cel) : applique la saisie selon la nature, compose le texte affiche, le texte
-- imprime et le comptage. @obligation : 'IMPOSEE', 'CONDITIONNELLE', 'FACULTATIVE', ou 'SANS' (NULL). @saisie_id :
-- NULL pour la saisie de la cle de la cellule a l'arrete, 0 pour aucune saisie, un identifiant de saisie_annexe sinon.
-- @ops : les operandes, « article|ligne|colonne » separes par « ; ». Une cellule deja presente est remplacee.
CREATE   PROCEDURE dbo.pr_ann_cel
    @c          INT,
    @a          VARCHAR (20),
    @art        VARCHAR (10),
    @ligne      NVARCHAR (120),
    @col        TINYINT,
    @etat       VARCHAR (12),
    @valeur     DECIMAL (38, 12) = NULL,
    @fmt        VARCHAR (10)     = 'montant',
    @source     NVARCHAR (MAX)   = N'',
    @formule    NVARCHAR (MAX)   = NULL,
    @regle      VARCHAR (12)     = '',
    @obligation VARCHAR (14)     = 'IMPOSEE',
    @nature     VARCHAR (8)      = 'source',
    @libelle    NVARCHAR (500)   = NULL,
    @ordre      DECIMAL (19, 6)  = NULL,
    @motif      NVARCHAR (MAX)   = NULL,
    @ops        NVARCHAR (MAX)   = NULL,
    @texte      NVARCHAR (2000)  = NULL,
    @signe      VARCHAR (4)      = NULL,
    @saisie_id  INT              = NULL,
    @groupe     VARCHAR (40)     = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @nature NOT IN ('texte', 'source', 'etat', 'calcul', 'modele')
        THROW 50659, N'Moteur de l''annexe : nature de cellule inconnue.', 1;
    DECLARE @entite VARCHAR (20) = (SELECT entite FROM dbo.calcul_annexe WHERE calcul_id = @c);
    DECLARE @lib NVARCHAR (500) = @libelle, @od DECIMAL (19, 6) = @ordre;
    IF @lib IS NULL OR @od IS NULL
    BEGIN
        SELECT @lib = ISNULL(@lib, l.libelle), @od = ISNULL(@od, l.ordre) FROM dbo.ref_ligne_annexe l
        WHERE l.article = @art AND l.code = @ligne;
    END;
    DECLARE @ob VARCHAR (14) = NULLIF(@obligation, 'SANS');
    DECLARE @val DECIMAL (38, 12) = CASE WHEN @fmt <> 'texte' THEN @valeur END;
    DECLARE @tv NVARCHAR (2000) = @texte;
    DECLARE @et VARCHAR (12) = @etat, @src NVARCHAR (MAX) = @source, @ecartee NVARCHAR (400) = NULL,
            @vbn DECIMAL (38, 12) = NULL, @vbt NVARCHAR (2000) = NULL;
    -- la saisie
    DECLARE @s_val NVARCHAR (4000), @s_mt DECIMAL (19, 2), @s_motif NVARCHAR (1600), @s_trouvee BIT = 0;
    IF @saisie_id IS NULL
        SELECT TOP (1) @s_val = s.valeur, @s_mt = s.montant, @s_motif = s.motif, @s_trouvee = 1 FROM dbo.saisie_annexe s
        WHERE s.entite = @entite AND s.arrete = @a AND s.article = @art AND s.ligne = @ligne
          AND LTRIM(RTRIM(s.colonne)) = CAST(@col AS NVARCHAR (4))
        ORDER BY s.id DESC;
    ELSE IF @saisie_id > 0
        SELECT @s_val = s.valeur, @s_mt = s.montant, @s_motif = s.motif, @s_trouvee = 1 FROM dbo.saisie_annexe s WHERE s.id = @saisie_id;
    IF @s_trouvee = 1
    BEGIN
        DECLARE @base_connue BIT = CASE WHEN @et IN ('LU', 'CALCULE', 'SAISI') THEN 1 ELSE 0 END;
        DECLARE @est_texte BIT = CASE WHEN @s_val IS NOT NULL AND @s_val <> N'' THEN 1 ELSE 0 END;
        IF @nature = 'modele'
            SET @ecartee = N'écartée : la cellule est sans objet au modèle du recueil (refus 50643)';
        ELSE IF @nature = 'calcul'
            SET @ecartee = N'écartée : la cellule se calcule sur d’autres cellules de l’annexe (refus 50644)';
        ELSE IF @nature = 'etat' AND @base_connue = 1
            SET @ecartee = N'écartée : la cellule reproduit une ligne du bilan ou du compte de résultat qui a une valeur (article 331-1, p. 96 ; refus 50646)';
        ELSE IF @fmt = 'texte' AND @est_texte = 0
            SET @ecartee = N'écartée : un montant dans une colonne de texte (refus 50645)';
        ELSE IF @fmt <> 'texte' AND @est_texte = 1
            SET @ecartee = N'écartée : un texte dans une colonne de montants (refus 50645)';
        ELSE
        BEGIN
            IF @base_connue = 1
            BEGIN
                IF @tv IS NOT NULL SET @vbt = @tv;
                ELSE IF @fmt = 'texte' SET @vbt = NULL;
                ELSE SET @vbn = @val;
            END;
            SET @et = 'SAISI';
            SET @src = N'saisie du cabinet' + CASE WHEN NULLIF(@s_motif, N'') IS NOT NULL THEN N', motif : ' + @s_motif ELSE N'' END;
            IF @est_texte = 1 SELECT @tv = @s_val, @val = NULL;
            ELSE SELECT @val = @s_mt, @tv = NULL;
        END;
    END;
    -- les textes
    DECLARE @texte_aff NVARCHAR (2000) =
        CASE WHEN @et = 'A_REMPLIR' THEN N'à remplir'
             WHEN @et = 'EN_ATTENTE' THEN N'calcul en attente'
             WHEN @et = 'SANS_OBJET' THEN N''
             WHEN @tv IS NOT NULL THEN @tv
             WHEN @fmt = 'texte' THEN NULL
             ELSE dbo.fn_ann_format(@fmt, @val) END;
    DECLARE @rang INT = ISNULL((SELECT MAX(rang) FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a), 0) + 1;
    DELETE dbo.annexe_w_ops WHERE calcul_id = @c AND arrete = @a AND article = @art AND ligne = @ligne AND colonne = @col;
    DELETE dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a AND article = @art AND ligne = @ligne AND colonne = @col;
    INSERT INTO dbo.annexe_w_cel (calcul_id, arrete, article, ligne, colonne, etat, valeur, texte_valeur, fmt, source, formule,
                                  regle, obligation, nature, motif, vb_num, vb_txt, saisie_ecartee, libelle, ordre_declare,
                                  signe, groupe, rang, texte, texte_imprime)
    VALUES (@c, @a, @art, @ligne, @col, @et, @val, @tv, @fmt, @src, @formule, NULLIF(@regle, ''), @ob, @nature, @motif,
            @vbn, @vbt, @ecartee, @lib, @od, @signe, @groupe, @rang, @texte_aff,
            CASE WHEN @et IN ('LU', 'CALCULE', 'SAISI') THEN @texte_aff ELSE N'' END);
    IF @ops IS NOT NULL AND @ops <> N''
        INSERT INTO dbo.annexe_w_ops (calcul_id, arrete, article, ligne, colonne, n, op_article, op_ligne, op_colonne)
        SELECT @c, @a, @art, @ligne, @col, x.ordinal,
               PARSENAME(REPLACE(REPLACE(x.value, N'.', NCHAR(2)), N'|', N'.'), 3),
               REPLACE(PARSENAME(REPLACE(REPLACE(x.value, N'.', NCHAR(2)), N'|', N'.'), 2), NCHAR(2), N'.'),
               CAST(PARSENAME(REPLACE(REPLACE(x.value, N'.', NCHAR(2)), N'|', N'.'), 1) AS TINYINT)
        FROM STRING_SPLIT(@ops, N';', 1) x WHERE LTRIM(RTRIM(x.value)) <> N'';
END;

GO

