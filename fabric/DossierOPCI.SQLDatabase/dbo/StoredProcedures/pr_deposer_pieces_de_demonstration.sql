
-- DEPOSER LES PIECES DE DEMONSTRATION dans le site SharePoint du vehicule, par
-- dbo.pr_deposer_fichier_espace, et poser leur lien sur la fiche.
-- REJOUABLE : une fiche qui porte deja son lien est passee, sauf @redeposer = 1. Relancer apres un
-- refus reprend la ou l'on s'etait arrete.
-- LA BIBLIOTHEQUE SE LIT DANS LE CHEMIN DU COFFRE : /Coffre/sp_<vehicule>_annuel/... est la
-- bibliotheque « Dossier annuel », _permanent le « Dossier permanent ». Le dossier et le fichier
-- suivent le nom du raccourci.
CREATE   PROCEDURE dbo.pr_deposer_pieces_de_demonstration
    @par        NVARCHAR (400),
    @redeposer  BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF @par IS NULL OR LEN(@par) = 0
        THROW 50960, N'Dites qui dépose : @par est obligatoire.', 1;
    DECLARE @bilan TABLE (piece_id INT, resultat NVARCHAR (400));
    DECLARE @id INT, @nom VARCHAR (400), @chemin NVARCHAR (400), @nature VARCHAR (40), @entite VARCHAR (20), @empreinte VARCHAR (64);
    DECLARE c CURSOR LOCAL FAST_FORWARD FOR
        SELECT id, nom_fichier, chemin_coffre, nature, entite, empreinte_sha256 FROM dbo.piece
        WHERE chemin_coffre LIKE N'/Coffre/sp[_]%' AND (web_url IS NULL OR @redeposer = 1) ORDER BY id;
    OPEN c;
    FETCH NEXT FROM c INTO @id, @nom, @chemin, @nature, @entite, @empreinte;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            IF @entite IS NULL
                THROW 50961, N'La fiche ne dit pas de quelle entité elle relève (colonne entite).', 1;
            -- /Coffre/<raccourci>/<dossier eventuel>/<fichier>
            DECLARE @reste NVARCHAR (400) = SUBSTRING(@chemin, LEN(N'/Coffre/') + 1, 400);
            DECLARE @raccourci NVARCHAR (200) = LEFT(@reste, CHARINDEX(N'/', @reste) - 1);
            SET @reste = SUBSTRING(@reste, LEN(@raccourci) + 2, 400);
            DECLARE @dossier NVARCHAR (400) = CASE WHEN CHARINDEX(N'/', @reste) > 0
                     THEN LEFT(@reste, LEN(@reste) - CHARINDEX(N'/', REVERSE(@reste))) ELSE N'' END;
            DECLARE @bibliotheque NVARCHAR (200) = CASE
                     WHEN @raccourci LIKE N'%[_]annuel' THEN N'Dossier annuel'
                     WHEN @raccourci LIKE N'%[_]permanent' THEN N'Dossier permanent'
                     WHEN @raccourci LIKE N'%[_]depot' THEN N'Dépôt du client'
                     WHEN @raccourci LIKE N'%[_]livrables' THEN N'Livrables' END;
            IF @bibliotheque IS NULL
                THROW 50962, N'Le chemin du coffre ne désigne aucune des 4 bibliothèques.', 1;
            DECLARE @pdf VARBINARY (MAX) = dbo.fn_pdf_piece_de_demonstration(@nom,
                     'Piece de demonstration sans contenu, fiche ' + CAST(@id AS VARCHAR) + ', nature ' + @nature);
            IF LOWER(CONVERT(VARCHAR (64), HASHBYTES('SHA2_256', @pdf), 2)) <> LOWER(@empreinte)
                THROW 50963, N'Le PDF fabriqué ne porte pas l''empreinte de la fiche : il n''est pas déposé.', 1;
            DECLARE @b64 NVARCHAR (MAX) = JSON_VALUE((SELECT @pdf AS b FOR JSON PATH, WITHOUT_ARRAY_WRAPPER), '$.b');
            DECLARE @r TABLE (web_url NVARCHAR (800), entite_legale NVARCHAR (MAX), message NVARCHAR (MAX));
            DELETE FROM @r;
            INSERT INTO @r EXEC dbo.pr_deposer_fichier_espace @entite = @entite, @bibliotheque = @bibliotheque,
                 @dossier = @dossier, @fichier = @nom, @contenu_base64 = @b64, @par = @par;
            UPDATE dbo.piece SET web_url = (SELECT web_url FROM @r) WHERE id = @id;
            INSERT INTO @bilan VALUES (@id, N'déposée' + CASE WHEN (SELECT entite_legale FROM @r) = 'POSEE'
                     THEN N'' ELSE N', entité légale non posée : ' + LEFT(ISNULL((SELECT entite_legale FROM @r), N''), 300) END);
        END TRY
        BEGIN CATCH
            INSERT INTO @bilan VALUES (@id, LEFT(N'REFUS ' + CAST(ERROR_NUMBER() AS NVARCHAR) + N' : ' + ERROR_MESSAGE(), 400));
        END CATCH;
        FETCH NEXT FROM c INTO @id, @nom, @chemin, @nature, @entite, @empreinte;
    END;
    CLOSE c; DEALLOCATE c;
    SELECT N'Pièces déposées : ' + CAST(SUM(CASE WHEN resultat LIKE N'déposée%' THEN 1 ELSE 0 END) AS NVARCHAR)
         + N', refusées : ' + CAST(SUM(CASE WHEN resultat LIKE N'REFUS%' THEN 1 ELSE 0 END) AS NVARCHAR)
         + N', restant sans lien : ' + CAST((SELECT COUNT(*) FROM dbo.piece WHERE web_url IS NULL) AS NVARCHAR) AS bilan
    FROM @bilan;
    SELECT piece_id, resultat FROM @bilan WHERE resultat NOT LIKE N'déposée' ORDER BY piece_id;
END;

GO

