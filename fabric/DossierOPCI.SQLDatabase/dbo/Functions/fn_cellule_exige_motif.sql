
-- 1. LA CELLULE QUI EXIGE UN MOTIF.
CREATE   FUNCTION dbo.fn_cellule_exige_motif (
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @article VARCHAR (10),
    @ligne   NVARCHAR (300),
    @colonne NVARCHAR (120)
)
RETURNS BIT
AS
BEGIN
    -- la colonne N-1 d'un etat ne se saisit qu'au 1er exercice suivi : elle porte toujours sur un exercice anterieur
    IF @article IN ('321-2', '321-6', '322-2') RETURN 1;
    IF EXISTS (SELECT 1 FROM dbo.ref_ligne_annexe l
               WHERE l.article = @article AND l.code = @ligne
                 AND (l.type_ligne IN ('CALCUL', 'TOTAL') OR l.racines IS NOT NULL OR l.formule_calcul IS NOT NULL))
        RETURN 1;
    IF @colonne = N'2' AND EXISTS (SELECT 1 FROM dbo.v_arrete_etat a WHERE a.entite = @entite AND a.arrete = @arrete AND a.premier_exercice = 1)
        RETURN 1;
    RETURN 0;
END;

GO

