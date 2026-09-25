
-- --- 6. l'etape 6 de la maquette : planifier les arretes de l'exercice, ouvrir le premier ----------
CREATE   PROCEDURE dbo.pr_ecran_ouvrir_arrete
    @entite          VARCHAR (20),
    @exercice_debut  DATE,
    @exercice_fin    DATE,
    @periodicite_vl  VARCHAR (13),        -- ANNUELLE, SEMESTRIELLE, TRIMESTRIELLE
    @par             NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @message NVARCHAR (2000), @premier VARCHAR (20), @planifies INT = 0;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite AND est_client = 1)
            THROW 50261, N'Un arrêté s''ouvre sur un client du cabinet.', 1;
        IF @periodicite_vl NOT IN ('ANNUELLE', 'SEMESTRIELLE', 'TRIMESTRIELLE')
            THROW 50262, N'La périodicité de la VL est ANNUELLE, SEMESTRIELLE ou TRIMESTRIELLE.', 1;
        IF @exercice_debut >= @exercice_fin OR DATEDIFF(MONTH, @exercice_debut, @exercice_fin) > 23
            THROW 50263, N'L''exercice commence avant sa fin et ne dépasse pas 24 mois.', 1;

        BEGIN TRANSACTION;
        UPDATE dbo.ref_entite SET periodicite_vl = @periodicite_vl WHERE code = @entite;

        -- les dates d'arrete de l'exercice, a rebours depuis la cloture, selon la periodicite
        DECLARE @pas INT = CASE @periodicite_vl WHEN 'TRIMESTRIELLE' THEN 3 WHEN 'SEMESTRIELLE' THEN 6 ELSE 12 END;
        DECLARE @dates TABLE (d DATE PRIMARY KEY);
        DECLARE @d DATE = @exercice_fin;
        WHILE @d > @exercice_debut
        BEGIN
            INSERT INTO @dates VALUES (@d);
            SET @d = EOMONTH(DATEADD(MONTH, -@pas, @d));
        END;
        DECLARE @c CURSOR;
        SET @c = CURSOR FAST_FORWARD FOR SELECT d FROM @dates ORDER BY d;
        OPEN @c; FETCH NEXT FROM @c INTO @d;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = CONVERT(VARCHAR (10), @d, 23))
            BEGIN
                DECLARE @type VARCHAR (14) = CASE WHEN @d = @exercice_fin THEN 'ANNUEL'
                                                  WHEN @periodicite_vl = 'SEMESTRIELLE' THEN 'SEMESTRIEL'
                                                  ELSE 'INTERMEDIAIRE' END;
                EXEC dbo.pr_planifier_arrete @entite, @d, @exercice_fin, @type, @par;
                SET @planifies += 1;
            END;
            FETCH NEXT FROM @c INTO @d;
        END;
        CLOSE @c; DEALLOCATE @c;
        SET @premier = (SELECT CONVERT(VARCHAR (10), MIN(d), 23) FROM @dates);

        -- le questionnaire d'acceptation s'etait adosse a la cloture par defaut : s'il vise un
        -- arrete hors de cet exercice, il se re-adosse a la cloture retenue, et la ligne planifiee
        -- par defaut est retiree si plus rien ne la reference.
        DECLARE @cote VARCHAR (30) = 'ACC-' + @entite, @ancien VARCHAR (20);
        SELECT @ancien = arrete FROM dbo.feuille_travail WHERE cote = @cote;
        IF @ancien IS NOT NULL AND @ancien NOT IN (SELECT CONVERT(VARCHAR (10), d, 23) FROM @dates)
        BEGIN
            UPDATE dbo.feuille_travail SET arrete = CONVERT(VARCHAR (10), @exercice_fin, 23) WHERE cote = @cote;
            IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND (arrete = @ancien OR exercice = @ancien))
               AND NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND exercice = @ancien AND arrete <> @ancien)
               AND NOT EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE entite = @entite AND arrete = @ancien)
               AND NOT EXISTS (SELECT 1 FROM dbo.import_fec WHERE entite = @entite AND arrete = @ancien)
               AND NOT EXISTS (SELECT 1 FROM dbo.piece_rattachement WHERE entite = @entite AND arrete = @ancien)
                DELETE dbo.ref_arrete WHERE entite = @entite AND arrete = @ancien AND est_arrete_client = 1;
        END;
        COMMIT;

        -- ouvrir le premier arrete, si les portes le laissent passer
        BEGIN TRY
            IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @premier)
            BEGIN
                DECLARE @tp VARCHAR (14) = (SELECT type_arrete FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @premier);
                DECLARE @ex VARCHAR (20) = CONVERT(VARCHAR (10), @exercice_fin, 23);
                EXEC dbo.pr_ouvrir_arrete @entite, @premier, @tp, @par, @ex, NULL;
            END;
            SET @message = CAST(@planifies AS NVARCHAR (10)) + N' arrêté(s) planifié(s) sur l''exercice, périodicité '
                         + LOWER(@periodicite_vl) + N'. Arrêté ' + @premier + N' ouvert : la révision peut commencer.';
            UPDATE dbo.ref_arrete SET message_ecran = NULL, message_ecran_le = NULL, message_ecran_pour = NULL
             WHERE entite = @entite AND arrete = @premier;
        END TRY
        BEGIN CATCH
            IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
            SET @message = CAST(@planifies AS NVARCHAR (10)) + N' arrêté(s) planifié(s) sur l''exercice, périodicité '
                         + LOWER(@periodicite_vl) + N'. L''arrêté ' + @premier + N' n''est pas encore ouvert : '
                         + LEFT(ERROR_MESSAGE(), 1500) + N' L''ouverture se rejoue depuis la ligne de l''arrêté.';
            UPDATE dbo.ref_arrete
               SET message_ecran = LEFT(@message, 2000), message_ecran_le = SYSUTCDATETIME(), message_ecran_pour = LEFT(@par, 200)
             WHERE entite = @entite AND arrete = @premier;
        END CATCH;
        SELECT @premier AS arrete, @planifies AS planifies,
               CAST(CASE WHEN EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @premier) THEN 1 ELSE 0 END AS BIT) AS ouvert,
               @message AS message;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

GO

