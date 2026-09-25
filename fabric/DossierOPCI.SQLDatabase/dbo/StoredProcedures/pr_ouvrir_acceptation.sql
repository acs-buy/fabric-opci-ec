
-- 50068 : la feuille du questionnaire n'existe pas ou n'est pas de la
--         phase attendue.
-- 50069 : une question obligatoire de la phase est sans reponse.
-- 50070 : l'approbateur est le proposant. Separation des roles, comme le
--         declencheur du script 80 l'impose aux 6 autres natures.
-- 50071 : l'approbateur n'a pas le role que la nature exige.
-- 50072 : l'acceptation est deja approuvee, ou elle est refusee et doit
--         d'abord etre reprise.
CREATE   PROCEDURE dbo.pr_ouvrir_acceptation
    @entite      VARCHAR (20),
    @cote        VARCHAR (30),
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail f
                   WHERE f.cote = @cote AND f.entite = @entite
                     AND f.phase = 'ACCEPT')
    BEGIN
        DECLARE @m68 NVARCHAR (1200) =
            N'Ouverture refusée : la feuille « ' + @cote + N' » n''existe '
            + N'pas pour cette entité, ou elle n''est pas de la phase '
            + N'Acceptation. Créer la feuille du questionnaire '
            + N'd''acceptation, puis rouvrir.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
        VALUES ('pr_ouvrir_acceptation', @entite, @cote, @m68,
                N'Créer la feuille de la phase Acceptation pour cette entité.',
                @par, SYSUTCDATETIME());
        THROW 50068, @m68, 1;
    END;

    IF EXISTS (SELECT 1 FROM dbo.acceptation_mission
               WHERE entite = @entite)
        UPDATE dbo.acceptation_mission
        SET cote_questionnaire = @cote
        WHERE entite = @entite AND cote_questionnaire IS NULL;
    ELSE
        INSERT INTO dbo.acceptation_mission
            (entite, statut, decision, cote_questionnaire, cree_par, cree_le)
        VALUES (@entite, 'OUVERT', 'EN_ATTENTE', @cote, @par,
                SYSUTCDATETIME());
END;

GO

