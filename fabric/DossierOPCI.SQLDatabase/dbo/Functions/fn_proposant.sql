-- fn_proposant lit desormais la nature EVALUATION.
CREATE   FUNCTION dbo.fn_proposant
    (@nature VARCHAR (12), @objet_ref VARCHAR (30))
RETURNS NVARCHAR (200)
AS
BEGIN
    DECLARE @qui NVARCHAR (200);
    IF @nature = 'LOT'
        SET @qui = (SELECT l.cree_par FROM dbo.lot_ecritures l
                    WHERE l.id = TRY_CAST(@objet_ref AS INT));
    ELSE IF @nature = 'CONCLUSION'
        SET @qui = (SELECT f.preparateur FROM dbo.feuille_travail f
                    WHERE f.cote = @objet_ref);
    ELSE IF @nature = 'DEROGATION'
        SET @qui = (SELECT d.accordee_par FROM dbo.derogation d
                    WHERE d.id = TRY_CAST(@objet_ref AS INT));
    ELSE IF @nature = 'EVALUATION'
        SET @qui = (SELECT e.propose_par FROM dbo.evaluation_actif e
                    WHERE e.id = TRY_CAST(@objet_ref AS INT));
    ELSE IF @nature = 'PUBLICATION'
        SET @qui = (SELECT TOP (1) l.cree_par FROM dbo.lot_ecritures l
                    WHERE l.entite + '|' + l.arrete = @objet_ref
                    ORDER BY l.cree_le DESC);
    ELSE IF @nature = 'OBLIGATION'
        -- Le proposant de l'obligation est celui qui a publie la valeur
        -- liquidative de la cloture, la base de calcul en decoulant.
        SET @qui = (SELECT TOP (1) p.publie_par FROM dbo.publication_vl p
                    JOIN dbo.obligation_distribution o
                      ON o.entite = p.entite
                     AND o.id = TRY_CAST(@objet_ref AS INT)
                    WHERE p.entite = o.entite
                    ORDER BY p.id DESC);
    RETURN @qui;
END

GO

