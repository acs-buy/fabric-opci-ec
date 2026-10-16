
-- 334-8 : renvoi aux modeles du reglement ANC n° 2020-07, « le cas echeant, lorsque l'OPCI gere des actifs
-- financiers » (p. 101).
CREATE   PROCEDURE dbo.pr_ann_a_334_8 @c INT, @a VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @s8 NVARCHAR (MAX) = N'bilan actif, lignes du poste ' + dbo.fn_ann_nom_etat('A_FIN') + N' nulles : aucun actif financier à la clôture';
    IF NOT EXISTS (SELECT 1 FROM dbo.annexe_w_arr WHERE calcul_id = @c AND arrete = @a AND porte_balance = 1)
    BEGIN
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '334-8', @ligne = N'RENVOI_2020_07', @col = 1,
             @motif = N'arrêté sans balance : la base ne dit pas si l’OPCI gère des actifs financiers',
             @obligation = 'CONDITIONNELLE', @fmt = 'texte', @nature = 'texte', @regle = 'TXT';
        RETURN;
    END;
    DECLARE @ob VARCHAR (14) = dbo.fn_ann_cas_echeant(@c, @a, 'A_FIN_1,A_FIN_2,A_FIN_3,A_FIN_4,A_FIN_5,A_FIN_6,A_FIN_7');
    IF @ob = 'NEANT'
        EXEC dbo.pr_ann_neant @c = @c, @a = @a, @art = '334-8', @ligne = N'RENVOI_2020_07', @col = 1,
             @source = @s8;
    ELSE
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = '334-8', @ligne = N'RENVOI_2020_07', @col = 1,
             @motif = N'expositions selon les modèles du règlement ANC n° 2020-07', @obligation = @ob, @fmt = 'texte',
             @nature = 'texte', @regle = 'TXT';
END;

GO

