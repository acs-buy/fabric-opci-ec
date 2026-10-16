
CREATE   PROCEDURE dbo.pr_ann_cb_a_saisir @c INT, @a VARCHAR (20), @motif NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @art VARCHAR (10) = '334-3', @l NVARCHAR (40) = N'CB:SAISIE';
    DECLARE @n1 VARCHAR (20) = (SELECT arrete_n_1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a);
    DECLARE @m NVARCHAR (600) = @motif + N' : contrats de crédit-bail de l’exercice non établis';
    DECLARE @cols TABLE (n INT, col TINYINT);
    INSERT INTO @cols VALUES (1, 3), (2, 2), (3, 4), (4, 5), (5, 6), (6, 1);
    DECLARE @col TINYINT;
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR SELECT col FROM @cols ORDER BY n;
    OPEN cur; FETCH NEXT FROM cur INTO @col;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @col = 1 AND dbo.fn_ann_balance(@c, @a) = 1
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 1, @etat = 'LU', @valeur = 0,
                 @source = N'comptes 243 et 274 nuls à la clôture : aucun contrat n’a de valeur à N', @libelle = N'Contrat de crédit-bail', @ordre = 7.5, @regle = 'A334_3';
        ELSE IF @col = 2 AND dbo.fn_ann_connue(@c, @n1, @art, N'TOTAL', 1) = 1 AND dbo.fn_ann_val(@c, @n1, @art, N'TOTAL', 1) = 0
        BEGIN
            DECLARE @s NVARCHAR (MAX) = N'annexe de l’arrêté du ' + dbo.fn_ann_arrete_fr(@c, @n1) + N' : ' + dbo.fn_ann_designer(@c, @n1, '334-3', N'TOTAL', 1) + N', nulle, aucun contrat n’y avait de valeur';
            EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @l, @col = 2, @etat = 'CALCULE', @valeur = 0, @source = @s,
                 @libelle = N'Contrat de crédit-bail', @ordre = 7.5, @regle = 'A334_3';
        END;
        ELSE
            EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @l, @col = @col, @motif = @m, @libelle = N'Contrat de crédit-bail', @ordre = 7.5, @regle = 'A334_3';
        FETCH NEXT FROM cur INTO @col;
    END;
    CLOSE cur;
    OPEN cur; FETCH NEXT FROM cur INTO @col;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @t NVARCHAR (100) = N'1|334-3|CB:SAISIE|' + CAST(@col AS NVARCHAR (2));
        EXEC dbo.pr_ann_somme @c = @c, @a = @a, @art = @art, @ligne = N'TOTAL', @col = @col, @termes = @t;
        FETCH NEXT FROM cur INTO @col;
    END;
    CLOSE cur; DEALLOCATE cur;
    DECLARE @code VARCHAR (24);
    DECLARE cur2 CURSOR LOCAL FAST_FORWARD FOR
        SELECT code FROM (VALUES (1, 'ASSIETTE'), (2, 'REDEVANCES_N'), (3, 'REDEVANCES_CUM'), (4, 'RESTANT_1AN'), (5, 'RESTANT_1_5ANS'),
            (6, 'RESTANT_5ANS')) x (n, code) ORDER BY n;
    OPEN cur2; FETCH NEXT FROM cur2 INTO @code;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @code, @col = 1, @motif = @motif, @regle = 'A334_3';
        FETCH NEXT FROM cur2 INTO @code;
    END;
    CLOSE cur2; DEALLOCATE cur2;
    EXEC dbo.pr_ann_prix_residuel @c = @c, @a = @a, @mode = 'AR', @motif = @motif;
END;

GO

