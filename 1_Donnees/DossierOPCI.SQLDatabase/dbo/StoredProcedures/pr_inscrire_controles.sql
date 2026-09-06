
-- --- 2 : l'inscription automatique -----------------------------------
CREATE   PROCEDURE dbo.pr_inscrire_controles
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.pr_debut_semis;

    DECLARE @rang INT = ISNULL((SELECT MAX(ordre) FROM dbo.ref_controle), 0);

    -- Le libelle par defaut derive du nom de la vue : « controle
    -- immeuble non qualifie » se lit deja, et l'associe le precisera.
    INSERT INTO dbo.ref_controle (vue, code, libelle, genre,
                                  condition_anomalie, fondement, ordre)
    SELECT v.name, NULL,
           REPLACE(SUBSTRING(v.name, 3, 200), '_', ' '),
           'ZERO_ATTENDU', NULL,
           N'inscrit automatiquement, à qualifier par l''associé',
           @rang + ROW_NUMBER() OVER (ORDER BY v.name)
    FROM sys.views v
    WHERE v.name LIKE 'v_controle%'
      -- La vue du tableau de bord porte le meme prefixe et n'est pas un
      -- controle : s'inscrire elle-meme la ferait compter ses propres
      -- lignes, et le tableau de bord se mesurerait lui-meme.
      AND v.name <> 'v_controle_en_anomalie'
      AND NOT EXISTS (SELECT 1 FROM dbo.ref_controle c WHERE c.vue = v.name);

    EXEC dbo.pr_fin_semis;
END;

GO

