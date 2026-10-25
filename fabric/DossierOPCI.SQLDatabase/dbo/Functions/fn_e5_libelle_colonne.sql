-- ------------------------------------------------------------------ le libelle d'une colonne : celui de sa table, sinon celui de « * », sinon son nom
-- ecran 5, lot 1, script 323 (61_DEPLOIEMENT/generer_e5_323_procedures_de_tenue.py)
CREATE   FUNCTION dbo.fn_e5_libelle_colonne (@table VARCHAR (120), @colonne SYSNAME)
RETURNS NVARCHAR (128)
AS
BEGIN
    RETURN COALESCE((SELECT TOP (1) l.libelle FROM dbo.ref_libelle_colonne l WHERE l.vue = @table AND l.colonne = @colonne),
                    (SELECT TOP (1) l.libelle FROM dbo.ref_libelle_colonne l WHERE l.vue = '*' AND l.colonne = @colonne),
                    CAST(@colonne AS NVARCHAR (128)));
END;

GO

