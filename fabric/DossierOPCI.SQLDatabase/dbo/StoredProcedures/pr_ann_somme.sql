
-- Regle T (oracle, Table.somme) : sans objet si tous les operandes le sont ; en attente si l'un est a remplir ou en
-- attente ; sinon la somme signee. @termes : « signe|article|ligne|colonne » separes par « ; », le signe valant 1 ou
-- -1. La formule par defaut est celle de l'oracle.
CREATE   PROCEDURE dbo.pr_ann_somme
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT, @termes NVARCHAR (MAX),
    @regle VARCHAR (12) = 'RC4', @formule NVARCHAR (MAX) = NULL, @fmt VARCHAR (10) = 'montant',
    @nature VARCHAR (8) = 'calcul', @obligation VARCHAR (14) = 'SANS', @libelle NVARCHAR (500) = NULL,
    @ordre DECIMAL (19, 6) = NULL, @signe VARCHAR (4) = NULL, @groupe VARCHAR (40) = NULL, @saisie_id INT = NULL,
    @source NVARCHAR (MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @t TABLE (n INT, sg INT, art VARCHAR (10), ligne NVARCHAR (120), col TINYINT);
    INSERT INTO @t
    SELECT x.ordinal, CAST(PARSENAME(p.v, 4) AS INT), PARSENAME(p.v, 3), REPLACE(PARSENAME(p.v, 2), NCHAR(2), N'.'),
           CAST(PARSENAME(p.v, 1) AS TINYINT)
    FROM STRING_SPLIT(@termes, N';', 1) x
    CROSS APPLY (SELECT REPLACE(REPLACE(LTRIM(RTRIM(x.value)), N'.', NCHAR(2)), N'|', N'.') AS v) p
    WHERE LTRIM(RTRIM(x.value)) <> N'';
    DECLARE @f NVARCHAR (MAX) = @formule;
    IF @f IS NULL
        SELECT @f = STRING_AGG(CASE WHEN sg > 0 THEN N'+ ' ELSE N'- ' END + art + N' ' + ligne + N'[' + CAST(col AS NVARCHAR (4)) + N']', N' ')
                    WITHIN GROUP (ORDER BY n) FROM @t;
    DECLARE @ops NVARCHAR (MAX) = (SELECT STRING_AGG(art + N'|' + ligne + N'|' + CAST(col AS NVARCHAR (4)), N';') WITHIN GROUP (ORDER BY n) FROM @t);
    DECLARE @presents INT, @attente INT, @v DECIMAL (38, 12);
    SELECT @presents = COUNT(*),
           @attente = SUM(CASE WHEN w.etat IN ('A_REMPLIR', 'EN_ATTENTE') THEN 1 ELSE 0 END),
           @v = ISNULL(SUM(CASE WHEN w.valeur IS NOT NULL THEN t.sg * w.valeur END), 0)
    FROM @t t JOIN dbo.annexe_w_cel w ON w.calcul_id = @c AND w.arrete = @a AND w.article = t.art AND w.ligne = t.ligne AND w.colonne = t.col
    WHERE w.etat <> 'SANS_OBJET';
    IF @presents = 0
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'SANS_OBJET', @formule = @f,
             @regle = @regle, @ops = @ops, @fmt = @fmt, @nature = @nature, @obligation = @obligation, @libelle = @libelle,
             @ordre = @ordre, @signe = @signe, @groupe = @groupe, @saisie_id = @saisie_id, @source = N'';
    ELSE IF @attente > 0
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'EN_ATTENTE', @formule = @f,
             @regle = @regle, @ops = @ops, @motif = N'un opérande est à remplir ou en attente', @fmt = @fmt,
             @nature = @nature, @obligation = @obligation, @libelle = @libelle, @ordre = @ordre, @signe = @signe,
             @groupe = @groupe, @saisie_id = @saisie_id, @source = N'';
    ELSE
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'CALCULE', @valeur = @v,
             @formule = @f, @regle = @regle, @ops = @ops, @source = N'total ou report calculé sur d’autres cellules de l’annexe', @fmt = @fmt, @nature = @nature,
             @obligation = @obligation, @libelle = @libelle, @ordre = @ordre, @signe = @signe, @groupe = @groupe,
             @saisie_id = @saisie_id;
END;

GO

