-- ------------------------------------------------------------------ la designation d'une ligne et le nombre de lignes de son referentiel qui la portent
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
-- B13 : la designation (colonne ligne de v_ecran_referentiel_lignes, objet n° 6) est unique dans son referentiel ;
-- [Ligne du referentiel choisie] (B11) rend la plus grande cle des lignes de la designation choisie, et une 2e ligne de
-- meme designation ne se choisirait plus. Lue apres l'ecriture, dans la transaction de la procedure, par la cle de la
-- ligne ecrite (@cle1, sinon @cle2), avec la collation de la base, qui ignore la casse comme le modele.
CREATE   PROCEDURE dbo.pr_e5_designation
    @table  VARCHAR (120),
    @cle1   NVARCHAR (400),
    @cle2   NVARCHAR (400),
    @ligne  NVARCHAR (400) OUTPUT,
    @nombre INT            OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @ligne = NULL, @nombre = 0;
    IF OBJECT_ID(N'dbo.v_ecran_referentiel_lignes') IS NULL OR COALESCE(@cle1, @cle2) IS NULL RETURN;
    SELECT TOP (1) @ligne = l.ligne FROM dbo.v_ecran_referentiel_lignes l
    WHERE l.referentiel = @table AND l.cle IN (@cle1, @cle2)
    ORDER BY CASE WHEN l.cle = @cle1 THEN 0 ELSE 1 END
    OPTION (RECOMPILE);
    IF @ligne IS NULL RETURN;
    SELECT @nombre = COUNT(*) FROM dbo.v_ecran_referentiel_lignes l
    WHERE l.referentiel = @table AND l.ligne = @ligne
    OPTION (RECOMPILE);
END;

GO

