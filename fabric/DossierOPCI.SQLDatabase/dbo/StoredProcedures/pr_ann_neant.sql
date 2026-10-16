
-- Le constat « Néant » etabli par la base (oracle, Table.neant).
CREATE   PROCEDURE dbo.pr_ann_neant
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT, @source NVARCHAR (MAX),
    @regle VARCHAR (12) = 'NEANT', @obligation VARCHAR (14) = 'IMPOSEE', @nature VARCHAR (8) = 'source',
    @libelle NVARCHAR (500) = NULL, @ordre DECIMAL (19, 6) = NULL, @groupe VARCHAR (40) = NULL, @saisie_id INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'CALCULE', @fmt = 'texte',
         @texte = N'Néant', @source = @source, @regle = @regle, @obligation = @obligation, @nature = @nature,
         @libelle = @libelle, @ordre = @ordre, @groupe = @groupe, @saisie_id = @saisie_id;
END;

GO

