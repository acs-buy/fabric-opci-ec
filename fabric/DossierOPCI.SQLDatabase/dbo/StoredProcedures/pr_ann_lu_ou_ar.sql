
-- Lu en base, ou a remplir sans valeur (oracle, Table.lu_ou_ar).
CREATE   PROCEDURE dbo.pr_ann_lu_ou_ar
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT, @v DECIMAL (38, 12),
    @source NVARCHAR (MAX), @motif NVARCHAR (MAX) = N'donnée absente de la base', @etat VARCHAR (12) = 'LU',
    @fmt VARCHAR (10) = 'montant', @regle VARCHAR (12) = 'RL', @obligation VARCHAR (14) = 'IMPOSEE',
    @nature VARCHAR (8) = 'source', @libelle NVARCHAR (500) = NULL, @ordre DECIMAL (19, 6) = NULL,
    @formule NVARCHAR (MAX) = NULL, @ops NVARCHAR (MAX) = NULL, @saisie_id INT = NULL, @groupe VARCHAR (40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @v IS NULL
        EXEC dbo.pr_ann_ar @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @motif = @motif, @source = @source,
             @fmt = @fmt, @regle = @regle, @obligation = @obligation, @nature = @nature, @libelle = @libelle,
             @ordre = @ordre, @formule = @formule, @ops = @ops, @saisie_id = @saisie_id, @groupe = @groupe;
    ELSE
        EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = @etat, @valeur = @v,
             @source = @source, @fmt = @fmt, @regle = @regle, @obligation = @obligation, @nature = @nature,
             @libelle = @libelle, @ordre = @ordre, @formule = @formule, @ops = @ops, @saisie_id = @saisie_id,
             @groupe = @groupe;
END;

GO

