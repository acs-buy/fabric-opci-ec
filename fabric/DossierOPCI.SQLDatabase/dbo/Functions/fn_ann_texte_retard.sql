
-- Le texte du refus 50649, seul en base (fn_documents le lit avant le depot, pr_enregistrer_document le leve) : la
-- source de la plus ancienne marque de l'entite, en clair, et son heure de Paris ; NULL sans marque.
CREATE   FUNCTION dbo.fn_ann_texte_retard (@entite VARCHAR (20))
RETURNS NVARCHAR (800)
AS
BEGIN
    DECLARE @origine NVARCHAR (128), @depuis DATETIME2 (3);
    SELECT TOP (1) @origine = origine, @depuis = ecrit_le FROM dbo.annexe_retard WHERE entite = @entite ORDER BY ecrit_le, id;
    IF @depuis IS NULL RETURN NULL;
    DECLARE @paris DATETIME2 (0) = CAST(CAST(@depuis AS DATETIME2 (0)) AT TIME ZONE 'UTC' AT TIME ZONE 'Romance Standard Time' AS DATETIME2 (0));
    RETURN N'Document refusé : les cellules de l’annexe de ' + dbo.fn_ann_nom_entite(@entite) + N' sont en retard sur une modification '
         + dbo.fn_ann_origine_fr(@origine) + N' du ' + CONVERT(NVARCHAR (10), @paris, 103) + N' à ' + LEFT(CONVERT(NVARCHAR (8), @paris, 108), 5)
         + N' ; recalculez, puis produisez de nouveau.';
END;

GO

