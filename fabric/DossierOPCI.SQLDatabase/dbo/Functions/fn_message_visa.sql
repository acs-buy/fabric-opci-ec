
-- Le message d'un visa reussi, en francais, par nature, objet et decision (pr_ecran_viser ne rend pas de ligne).
CREATE   FUNCTION dbo.fn_message_visa (@nature VARCHAR (20), @objet_ref VARCHAR (60), @decision VARCHAR (10))
RETURNS NVARCHAR (400)
AS
BEGIN
    DECLARE @v BIT = CASE WHEN @decision = 'VISE' THEN 1 ELSE 0 END;
    DECLARE @n INT = TRY_CAST(@objet_ref AS INT);
    RETURN CASE @nature
        WHEN 'LOT' THEN N'Lot n° ' + @objet_ref + CASE WHEN @v = 1 THEN N' visé.' ELSE N' renvoyé au préparateur.' END
        WHEN 'EVALUATION' THEN N'Valeur retenue de ' + ISNULL((SELECT TOP (1) code_actif FROM dbo.evaluation_actif WHERE id = @n), @objet_ref)
                                + CASE WHEN @v = 1 THEN N' visée.' ELSE N' renvoyée au préparateur.' END
        WHEN 'SYNTHESE' THEN N'Synthèse de l''arrêté ' + CASE WHEN @v = 1 THEN N'visée.' ELSE N'renvoyée au préparateur.' END
        WHEN 'CONCLUSION' THEN N'Conclusion ' + CASE WHEN @v = 1 THEN N'visée.' ELSE N'renvoyée au préparateur.' END
        WHEN 'DEROGATION' THEN N'Dérogation ' + CASE WHEN @v = 1 THEN N'visée.' ELSE N'renvoyée au préparateur.' END
        WHEN 'CYCLE' THEN N'Cycle ' + CASE WHEN @v = 1 THEN N'visé.' ELSE N'renvoyé au préparateur.' END
        WHEN 'REVUE' THEN N'Revue ' + CASE WHEN @v = 1 THEN N'visée.' ELSE N'renvoyée au préparateur.' END
        WHEN 'PUBLICATION' THEN N'Valeur liquidative publiée.'
        ELSE CASE WHEN @v = 1 THEN N'Visa enregistré.' ELSE N'Renvoi enregistré.' END END;
END;

GO

