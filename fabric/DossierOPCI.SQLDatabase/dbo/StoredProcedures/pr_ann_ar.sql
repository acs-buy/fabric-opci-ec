
-- A remplir (oracle, Table.ar) : comptee et saisissable ; la nature ne peut etre ni calcul ni modele, l'obligation
-- jamais nulle.
CREATE   PROCEDURE dbo.pr_ann_ar
    @c INT, @a VARCHAR (20), @art VARCHAR (10), @ligne NVARCHAR (120), @col TINYINT, @motif NVARCHAR (MAX),
    @fmt VARCHAR (10) = 'montant', @source NVARCHAR (MAX) = N'', @formule NVARCHAR (MAX) = NULL, @regle VARCHAR (12) = '',
    @obligation VARCHAR (14) = 'IMPOSEE', @nature VARCHAR (8) = 'source', @libelle NVARCHAR (500) = NULL,
    @ordre DECIMAL (19, 6) = NULL, @ops NVARCHAR (MAX) = NULL, @signe VARCHAR (4) = NULL, @saisie_id INT = NULL,
    @groupe VARCHAR (40) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @nature NOT IN ('texte', 'source', 'etat') SET @nature = 'source';
    IF @obligation = 'SANS' SET @obligation = 'IMPOSEE';
    EXEC dbo.pr_ann_cel @c = @c, @a = @a, @art = @art, @ligne = @ligne, @col = @col, @etat = 'A_REMPLIR', @fmt = @fmt,
         @source = @source, @formule = @formule, @regle = @regle, @obligation = @obligation, @nature = @nature,
         @libelle = @libelle, @ordre = @ordre, @motif = @motif, @ops = @ops, @signe = @signe, @saisie_id = @saisie_id,
         @groupe = @groupe;
END;

GO

