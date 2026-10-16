
-- La peremption des documents d'un arrete par une version neuve (contrat, 2.3) : chaque document COMPTES_ANNUELS ou
-- ATTESTATION non perime, de annexe_version v < @w, passe perime si au moins une cellule s'imprime autrement entre v et
-- @w. Un document sans version n'est pas touche. Rend le nombre de documents perimes.
CREATE   PROCEDURE dbo.pr_ann_perimer_documents
    @entite VARCHAR (20), @arrete VARCHAR (20), @w INT, @declencheur VARCHAR (12), @par NVARCHAR (400), @maintenant DATETIME2 (3),
    @perimes INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @perimes = 0;
    DECLARE @id INT, @v INT, @n INT, @art VARCHAR (10), @lig NVARCHAR (120), @col TINYINT, @anc NVARCHAR (2000), @nou NVARCHAR (2000), @m NVARCHAR (MAX);
    DECLARE cur CURSOR LOCAL FAST_FORWARD FOR
        SELECT id, annexe_version FROM dbo.document_produit
        WHERE entite = @entite AND arrete = @arrete AND livrable IN ('COMPTES_ANNUELS', 'ATTESTATION') AND perime_le IS NULL
          AND annexe_version IS NOT NULL AND annexe_version < @w
        ORDER BY id;
    OPEN cur; FETCH NEXT FROM cur INTO @id, @v;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @n = COUNT(*) FROM dbo.fn_annexe_imprime_autrement(@entite, @arrete, @v, @w);
        IF @n > 0
        BEGIN
            SELECT @art = article, @lig = ligne, @col = colonne, @anc = ancien, @nou = nouveau
            FROM dbo.fn_annexe_imprime_autrement(@entite, @arrete, @v, @w) WHERE rang = 1;
            SET @m = N'Périmé par le recalcul de l''annexe : version ' + CAST(@v AS NVARCHAR (10)) + N' du document, version ' + CAST(@w AS NVARCHAR (10))
                   + N' de l''annexe, ' + CAST(@n AS NVARCHAR (10)) + N' cellule(s) imprimée(s) autrement, dont ' + @art + N', ligne ' + @lig
                   + N', colonne ' + CAST(@col AS NVARCHAR (4)) + N' (' + ISNULL(N'« ' + @anc + N' »', N'cellule absente') + N' devenu '
                   + ISNULL(N'« ' + @nou + N' »', N'cellule absente') + N') ; déclencheur ' + @declencheur + N' ; par ' + ISNULL(@par, N'')
                   + N', le ' + CONVERT(NVARCHAR (19), @maintenant, 120) + N' UTC.';
            UPDATE dbo.document_produit SET perime_le = @maintenant, perime_motif = LEFT(@m, 600) WHERE id = @id AND perime_le IS NULL;
            SET @perimes += @@ROWCOUNT;
        END;
        FETCH NEXT FROM cur INTO @id, @v;
    END;
    CLOSE cur; DEALLOCATE cur;
END;

GO

