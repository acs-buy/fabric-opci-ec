
-- Sans objet (oracle, Table.so) : nature modele et sans obligation par defaut.
CREATE   PROCEDURE dbo.pr_ann_so
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT, @motif NVARCHAR (MAX) = N'',
    @fmt VARCHAR (10) = 'montant', @source NVARCHAR (MAX) = N'', @formule NVARCHAR (MAX) = NULL, @regle VARCHAR (12) = '',
    @obligation VARCHAR (14) = 'SANS', @nature VARCHAR (8) = 'modele', @libelle NVARCHAR (500) = NULL,
    @ordre DECIMAL (19, 6) = NULL, @ops NVARCHAR (MAX) = NULL, @signe VARCHAR (4) = NULL, @saisie_id INT = NULL,
    @groupe VARCHAR (40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'SANS_OBJET', @fmt = @fmt,
         @source = @source, @formule = @formule, @regle = @regle, @obligation = @obligation, @nature = @nature,
         @libelle = @libelle, @ordre = @ordre, @motif = @motif, @ops = @ops, @signe = @signe, @saisie_id = @saisie_id,
         @groupe = @groupe;
END;

GO

