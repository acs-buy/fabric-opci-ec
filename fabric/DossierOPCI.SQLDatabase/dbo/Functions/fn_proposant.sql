
-- ------------------------------------------------------------------ n° 7 : la branche OBLIGATION de fn_proposant

-- 5. LE PROPOSANT D'UN CYCLE : l'auteur de la conclusion en vigueur. REVUE et CLOTURE restent NULL : leur
-- reference porte 2 sortes de decisions dont le proposant differe ; leurs procedures tiennent la separation.
CREATE   FUNCTION dbo.fn_proposant
    (@nature VARCHAR (12), @objet_ref VARCHAR (60))
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
        -- ecran 4, objet n° 7 (decision du 09/10/2026) : le reviseur propose la base, l'associe la vise
        SET @qui = (SELECT o.propose_par FROM dbo.obligation_distribution o
                    WHERE o.id = TRY_CAST(@objet_ref AS INT));
    ELSE IF @nature = 'CYCLE'
        -- « entite|arrete|cycle » ; une reference mal formee rend NULL
        SET @qui = (SELECT c.conclu_par FROM dbo.conclusion_cycle c
                    WHERE c.entite + '|' + c.arrete + '|' + c.cycle = @objet_ref);
    RETURN @qui;
END;

GO

