CREATE   PROCEDURE dbo.pr_poser_parametre
    @code   VARCHAR (40),
    @valeur NVARCHAR (800),
    @par    NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF @code IS NULL OR LTRIM(RTRIM(@code)) = ''
        THROW 50930, N'Le code du paramètre est obligatoire.', 1;
    -- 318 (ecran 5, objet n° 19) : ref_parametre est gardee (tr_ref_parametre_garde) et horodatee sur pose_par et
    -- pose_le (tr_ref_parametre_horodatage). Le MERGE s'ecrit sous le contexte semis, que la garde et
    -- l'horodatage laissent passer : l'installation, qui appelle cette procedure avec l'adresse de
    -- l'installateur, n'est pas jugee sur un role, et pose_par garde @par. La valeur d'avant du contexte
    -- est retablie apres le MERGE, refus compris. Un code absent s'inscrit en INSTALLATION ; une mise a
    -- jour ne change pas genre. Genere par 61_DEPLOIEMENT/generer_e5_318_tables_gardees.py.
    DECLARE @semis_avant SQL_VARIANT = SESSION_CONTEXT(N'semis');
    BEGIN TRY
        EXEC sp_set_session_context N'semis', 1;
        MERGE dbo.ref_parametre AS c
        USING (SELECT @code AS code) AS n ON c.code = n.code
        WHEN MATCHED THEN UPDATE SET valeur = @valeur, pose_par = @par, pose_le = SYSUTCDATETIME()
        WHEN NOT MATCHED THEN INSERT (code, valeur, pose_par, genre) VALUES (@code, @valeur, @par, 'INSTALLATION');
        EXEC sp_set_session_context N'semis', @semis_avant;
    END TRY
    BEGIN CATCH
        EXEC sp_set_session_context N'semis', @semis_avant;
        THROW;
    END CATCH;
    SELECT @code AS code, @valeur AS valeur, N'Paramètre enregistré.' AS message;
END;

GO

