
-- Une ligne de l'annexe dans un motif ou une source (oracle, Table.nom_ligne), lue dans la table de l'arrete @a.
CREATE   FUNCTION dbo.fn_ann_nom_ligne (@c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120))
RETURNS NVARCHAR (2000)
AS
BEGIN
    DECLARE @nom NVARCHAR (1600) = (SELECT nom FROM dbo.annexe_w_nom WHERE calcul_id = @c AND article = @art AND code = @ligne);
    IF @nom IS NOT NULL RETURN N'ligne ' + @nom;
    IF @art = '335-12' AND (@ligne LIKE N'ACPT[_]N[_]TOTAL' OR @ligne LIKE N'ACPT[_]N1[_]TOTAL' OR @ligne LIKE N'ACPT[_]N:%' OR @ligne LIKE N'ACPT[_]N1:%')
    BEGIN
        DECLARE @n1 BIT = CASE WHEN @ligne LIKE N'ACPT[_]N1%' THEN 1 ELSE 0 END;
        DECLARE @titre NVARCHAR (200) = N'« Acomptes versés au titre de l''exercice' + CASE WHEN @n1 = 1 THEN N' précédent' ELSE N'' END + N' »';
        IF @ligne LIKE N'%[_]TOTAL' RETURN N'ligne « Total acomptes » du tableau ' + @titre;
        DECLARE @reste NVARCHAR (120) = SUBSTRING(@ligne, CHARINDEX(N':', @ligne) + 1, 120);
        IF @reste = N'SAISIE' RETURN N'ligne du paiement à saisir du tableau ' + @titre;
        IF @reste = N'NEANT' RETURN N'ligne « Néant » du tableau ' + @titre;
        IF @reste LIKE N'[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]%'
            RETURN N'ligne du paiement du ' + dbo.fn_ann_date_fr(LEFT(@reste, 10))
                 + CASE WHEN LEN(@reste) > 11 THEN N' (' + SUBSTRING(@reste, 12, 10) + N'e)' ELSE N'' END + N' du tableau ' + @titre;
    END;
    -- revision 12.3 (3.6, point 12) : la ligne d'un immeuble (336-2) ou d'un contrat de credit-bail (334-3), dont le
    -- libelle est le code de l'actif, par l'adresse de l'actif, a defaut par son rang dans la table de l'arrete
    IF (@ligne LIKE N'IMM:%' OR @ligne LIKE N'CB:%')
    BEGIN
        DECLARE @pfx NVARCHAR (4) = LEFT(@ligne, CHARINDEX(N':', @ligne) - 1), @code_actif NVARCHAR (120) = SUBSTRING(@ligne, CHARINDEX(N':', @ligne) + 1, 120);
        IF @code_actif NOT IN (N'NEANT', N'SAISIE')
        BEGIN
            DECLARE @quoi NVARCHAR (80) = CASE @pfx WHEN N'IMM' THEN N'de l’immeuble' ELSE N'du contrat de crédit-bail de l’immeuble' END;
            DECLARE @adresse NVARCHAR (2000) = LTRIM(RTRIM((SELECT adresse FROM dbo.actif WHERE code = @code_actif)));
            IF NULLIF(@adresse, N'') IS NOT NULL RETURN N'ligne ' + @quoi + N' « ' + @adresse + N' »';
            DECLARE @rang INT = ISNULL((SELECT r FROM (SELECT ligne, ROW_NUMBER() OVER (ORDER BY dbo.fn_ann_cle_naturelle(ligne) COLLATE Latin1_General_100_BIN2) AS r
                                                      FROM (SELECT DISTINCT ligne FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a AND article = @art
                                                            AND ligne LIKE @pfx + N':%' AND SUBSTRING(ligne, LEN(@pfx) + 2, 120) NOT IN (N'NEANT', N'SAISIE')) d) x
                                       WHERE ligne = @ligne), 0);
            DECLARE @ord NVARCHAR (10) = CASE WHEN @rang = 1 THEN N'1er' ELSE CAST(@rang AS NVARCHAR (6)) + N'e' END;
            RETURN CASE @pfx WHEN N'IMM' THEN N'ligne du ' + @ord + N' immeuble de l’inventaire, sans adresse en base'
                             ELSE N'ligne du ' + @ord + N' contrat de crédit-bail, sans adresse en base' END;
        END;
    END;
    DECLARE @lib NVARCHAR (500), @groupe VARCHAR (40);
    SELECT TOP (1) @lib = libelle, @groupe = groupe FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a AND article = @art AND ligne = @ligne ORDER BY rang;
    SET @nom = N'ligne ' + dbo.fn_ann_guillemets(@lib);
    IF @groupe IS NOT NULL AND EXISTS (SELECT 1 FROM dbo.annexe_w_cel WHERE calcul_id = @c AND arrete = @a AND article = @art AND ligne <> @ligne
                                       AND dbo.fn_ann_libelle_recueil(libelle) = dbo.fn_ann_libelle_recueil(@lib))
    BEGIN
        IF EXISTS (SELECT 1 FROM dbo.ref_ligne_etat WHERE code = @groupe) SET @nom += N' du poste ' + dbo.fn_ann_nom_etat(@groupe);
        ELSE IF EXISTS (SELECT 1 FROM dbo.annexe_w_nom WHERE calcul_id = @c AND article = @art AND code = @groupe)
            SET @nom += N' sous ' + (SELECT nom FROM dbo.annexe_w_nom WHERE calcul_id = @c AND article = @art AND code = @groupe);
    END;
    RETURN @nom;
END;

GO

