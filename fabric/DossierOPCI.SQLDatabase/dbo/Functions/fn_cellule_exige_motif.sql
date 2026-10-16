
-- La cellule qui exige un motif (contrat, 3.3, point 8) : etats 321-2, 321-6, 322-2 ; colonne 2 du 1er exercice suivi ;
-- sinon l'etat de la cellule sans la saisie, dans la derniere version (LU ou CALCULE, ou SAISI recouvrant une valeur de
-- la base) ; a defaut de cellule, la regle de la ligne de ref_ligne_annexe.
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
    IF @article IN ('321-2', '321-6', '322-2') RETURN 1;
    IF @colonne = N'2' AND EXISTS (SELECT 1 FROM dbo.v_arrete_etat a WHERE a.entite = @entite AND a.arrete = @arrete AND a.premier_exercice = 1)
        RETURN 1;
    DECLARE @etat VARCHAR (12), @vb NVARCHAR (2000), @trouvee BIT = 0;
    SELECT @etat = c.etat, @vb = c.valeur_base, @trouvee = 1
    FROM dbo.v_annexe_version v
    JOIN dbo.cellule_annexe c ON c.entite = v.entite AND c.arrete = v.arrete AND c.version = v.derniere_version
    WHERE v.entite = @entite AND v.arrete = @arrete AND c.article = @article AND c.ligne = @ligne AND CAST(c.colonne AS NVARCHAR (4)) = @colonne;
    IF @trouvee = 1
        RETURN CASE WHEN @etat IN ('LU', 'CALCULE') OR (@etat = 'SAISI' AND @vb IS NOT NULL) THEN 1 ELSE 0 END;
    IF EXISTS (SELECT 1 FROM dbo.ref_ligne_annexe l
               WHERE l.article = @article AND l.code = @ligne
                 AND (l.type_ligne IN ('CALCUL', 'TOTAL') OR l.racines IS NOT NULL OR l.formule_calcul IS NOT NULL))
        RETURN 1;
    RETURN 0;
END;

GO

