
-- Regle RV (oracle, colonne_vue) : une colonne de la vue d'inventaire n'est lue que si la somme de ses lignes egale le
-- poste du bilan. @valeurs : les valeurs des lignes, une par ligne, NULL compris (table #rv de l'appelant, colonne v).
-- Rend @lue et @motif ; pose le signal S336_2_VUE.
CREATE   PROCEDURE dbo.pr_ann_colonne_vue @c INT, @a VARCHAR (20), @n INT, @nuls INT, @somme DECIMAL (38, 12), @cle NVARCHAR (60),
                                             @attendu DECIMAL (38, 12), @poste NVARCHAR (200), @rapproche NVARCHAR (120),
                                             @lue BIT OUTPUT, @motif NVARCHAR (MAX) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @lue = 1, @motif = NULL;
    -- revision 12.3 : la colonne par son intitule au Word, entre guillemets, et non par le nom de la colonne de la vue
    DECLARE @nom NVARCHAR (200) = N'« ' + CASE @cle WHEN N'prix_de_revient' THEN N'Prix de revient' WHEN N'valeur_actuelle' THEN N'Valeur actuelle'
        WHEN N'cout_de_revient_frais_exclus' THEN N'Coût de revient des titres frais exclus' WHEN N'valeur_actuelle_titres' THEN N'Valeur actuelle des titres comptabilisée' ELSE @cle END + N' »';
    IF @n = 0 RETURN;
    IF @attendu IS NULL
    BEGIN
        SELECT @lue = 0, @motif = N'arrêté sans balance : la colonne ' + @nom + N' de l’inventaire n’est pas rapprochée du bilan';
        RETURN;
    END;
    IF @nuls > 0
    BEGIN
        SELECT @lue = 0, @motif = CAST(@nuls AS NVARCHAR (10)) + N' ligne(s) de l’inventaire sans ' + @nom + N' : la colonne n’est pas rapprochée ' + @poste;
        RETURN;
    END;
    DECLARE @e DECIMAL (38, 12) = @somme - @attendu;
    EXEC dbo.pr_ann_controle @c = @c, @a = @a, @controle = 'S336_2_VUE', @cle = @rapproche, @ecart = @e;
    IF ABS(@e) > 0.005
        SELECT @lue = 0, @motif = N'la somme des lignes de l’inventaire, colonne ' + @nom + N' (' + dbo.fn_ann_format('montant', @somme) + N') diffère ' + @poste + N' ('
            + dbo.fn_ann_format('montant', @attendu) + N') de ' + dbo.fn_ann_format('montant', @e) + N' : la valeur de chaque ligne n’est pas établie';
END;

GO

