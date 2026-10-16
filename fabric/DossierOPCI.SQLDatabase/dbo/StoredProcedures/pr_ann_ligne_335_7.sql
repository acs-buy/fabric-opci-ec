
-- ------------------------------------------------------------------------------------------------- 335-7
CREATE   PROCEDURE dbo.pr_ann_ligne_335_7 @c INT, @a VARCHAR (20), @code VARCHAR (24), @ligne_cr VARCHAR (24), @detail VARCHAR (20), @toujours BIT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '335-7';
    DECLARE @ob VARCHAR (14) = dbo.fn_ann_cas_echeant(@c, @a, @ligne_cr);
    IF @ob = 'NEANT'
    BEGIN
        DECLARE @ob0 VARCHAR (14) = CASE WHEN @toujours = 1 THEN 'IMPOSEE' ELSE 'CONDITIONNELLE' END, @s0 NVARCHAR (MAX) = N'compte de résultat, ligne ' + dbo.fn_ann_nom_etat(@ligne_cr) + N' nulle';
        EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @source = @s0, @obligation = @ob0;
        RETURN;
    END;
    IF @toujours = 1 SET @ob = 'IMPOSEE';
    DECLARE @texte NVARCHAR (2000), @src NVARCHAR (400);
    IF @detail = 'produits'
    BEGIN
        DECLARE @s723 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '723', '', N'*', 0);
        IF @s723 IS NOT NULL AND @s723 + dbo.fn_ann_S(@c, @a, '728', '', N'*', 0) = 0
            SELECT @texte = N'Loyers : ' + dbo.fn_ann_format('montant', -dbo.fn_ann_S(@c, @a, '721', '', N'*', 0)) + N' ; charges facturées : '
                          + dbo.fn_ann_format('montant', -dbo.fn_ann_S(@c, @a, '722', '', N'*', 0)) + N' ; autres revenus immobiliers : 0,00',
                   @src = N'comptes 721, 722 ; 723 et 728 nuls';
    END;
    ELSE IF @detail = 'charges'
    BEGIN
        DECLARE @s622 DECIMAL (38, 12) = dbo.fn_ann_S(@c, @a, '622', '', N'*', 0);
        IF @s622 IS NOT NULL AND @s622 + dbo.fn_ann_S(@c, @a, '627', '', N'*', 0) + dbo.fn_ann_S(@c, @a, '628', '', N'*', 0) + dbo.fn_ann_S(@c, @a, '629', '', N'*', 0) = 0
            SELECT @texte = N'Charges ayant leur contrepartie en produits : ' + dbo.fn_ann_format('montant', dbo.fn_ann_S(@c, @a, '621', '', N'*', 0))
                          + N' ; charges d’entretien : ' + dbo.fn_ann_format('montant', dbo.fn_ann_S(@c, @a, '624', '', N'*', 0) + dbo.fn_ann_S(@c, @a, '625', '', N'*', 0))
                          + N' ; coût initial des éléments d’actifs renouvelés ou remplacés : ' + dbo.fn_ann_format('montant', dbo.fn_ann_S(@c, @a, '626', '', N'*', 0))
                          + N' ; autres charges : 0,00',
                   @src = N'comptes 621, 624, 625, 626 ; 622, 627, 628, 629 nuls';
    END;
    IF @texte IS NOT NULL
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @etat = 'CALCULE', @fmt = 'texte', @texte = @texte, @source = @src,
             @obligation = @ob, @nature = 'source', @regle = 'A335_7';
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = N'détail par nature absent de la base', @fmt = 'texte',
             @nature = 'texte', @obligation = @ob, @regle = 'TXT';
END;

GO

