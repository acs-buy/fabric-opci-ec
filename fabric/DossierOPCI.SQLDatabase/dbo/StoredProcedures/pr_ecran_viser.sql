
-- pr_ecran_viser aiguille aussi CYCLE et REVUE : objet_ref « entite|arrete|cycle » et « entite|arrete ».
CREATE   PROCEDURE dbo.pr_ecran_viser
    @nature     varchar(20),
    @objet_ref  varchar(60),
    @decision   varchar(8),
    @decide_par nvarchar(200),
    @motif      nvarchar(600) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @p1 int = CHARINDEX('|', @objet_ref);
    DECLARE @p2 int = CASE WHEN @p1 > 0 THEN CHARINDEX('|', @objet_ref, @p1 + 1) ELSE 0 END;
    IF @nature = 'CONCLUSION'
        EXEC dbo.pr_ecran_viser_conclusion @objet_ref, @decision, @decide_par, @motif;
    ELSE IF @nature = 'DEROGATION'
        EXEC dbo.pr_ecran_viser_derogation @derogation_id = @objet_ref, @decision = @decision, @decide_par = @decide_par, @motif = @motif;
    ELSE IF @nature = 'EVALUATION'
        EXEC dbo.pr_ecran_viser_evaluation @evaluation_id = @objet_ref, @decision = @decision, @decide_par = @decide_par, @motif = @motif;
    ELSE IF @nature = 'LOT'
        EXEC dbo.pr_ecran_viser_lot @lot_id = @objet_ref, @decision = @decision, @decide_par = @decide_par, @motif = @motif;
    ELSE IF @nature = 'CYCLE'
    BEGIN
        IF @p2 = 0 THROW 50103, N'Visa refusé : la référence d''un cycle s''écrit « entité|arrêté|cycle ».', 1;
        DECLARE @ce varchar(20) = LEFT(@objet_ref, @p1 - 1), @ca varchar(20) = SUBSTRING(@objet_ref, @p1 + 1, @p2 - @p1 - 1),
                @cc varchar(10) = SUBSTRING(@objet_ref, @p2 + 1, 10);
        EXEC dbo.pr_viser_cycle @ce, @ca, @cc, @decision, @decide_par, @motif;
    END
    ELSE IF @nature = 'REVUE'
    BEGIN
        IF @p1 = 0 THROW 50104, N'Visa refusé : la référence d''une revue s''écrit « entité|arrêté ».', 1;
        DECLARE @re varchar(20) = LEFT(@objet_ref, @p1 - 1), @ra varchar(20) = SUBSTRING(@objet_ref, @p1 + 1, 40);
        EXEC dbo.pr_viser_revue @re, @ra, @decision, @decide_par, @motif;
    END
    ELSE IF @nature = 'PUBLICATION'
    BEGIN
        IF @decision <> 'VISE'
            THROW 50101, N'Renvoi refusé : une publication de valeur liquidative se vise ou reste en attente, elle ne se renvoie pas.', 1;
        IF @p1 = 0
            THROW 50102, N'Visa refusé : la référence d''une publication s''écrit « entité|arrêté ».', 1;
        DECLARE @e varchar(20) = LEFT(@objet_ref, @p1 - 1), @a varchar(20) = SUBSTRING(@objet_ref, @p1 + 1, 40);
        EXEC dbo.pr_ecran_publier_vl @entite = @e, @arrete = @a, @par = @decide_par;
    END
    ELSE
        THROW 50100, N'Visa refusé : nature inconnue. Les natures visables sont la conclusion, la dérogation, l''évaluation, le lot, la publication, le cycle et la revue.', 1;
END;

GO

