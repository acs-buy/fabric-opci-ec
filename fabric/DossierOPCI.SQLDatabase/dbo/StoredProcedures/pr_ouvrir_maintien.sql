
-- Le maintien suit la meme regle. L'ecran C4 porte « Approuver le
-- maintien », grise tant que le questionnaire n'est pas complet.
CREATE   PROCEDURE dbo.pr_ouvrir_maintien
    @entite         VARCHAR (20),
    @arrete_conclu  VARCHAR (20),
    @cote           VARCHAR (30),
    @par            NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.feuille_travail f
                   WHERE f.cote = @cote AND f.entite = @entite
                     AND f.phase = 'MAINTIEN')
    BEGIN
        DECLARE @m NVARCHAR (1200) =
            N'Ouverture refusée : la feuille « ' + @cote + N' » n''existe '
            + N'pas pour cette entité, ou elle n''est pas de la phase '
            + N'Maintien.';
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, cote, message, geste,
             refuse_pour, refuse_le)
        VALUES ('pr_ouvrir_maintien', @entite, @arrete_conclu, @cote, @m,
                N'Créer la feuille de la phase Maintien pour cette entité.',
                @par, SYSUTCDATETIME());
        THROW 50068, @m, 1;
    END;

    IF EXISTS (SELECT 1 FROM dbo.maintien_mission
               WHERE entite = @entite AND arrete_conclu = @arrete_conclu)
        UPDATE dbo.maintien_mission SET cote_questionnaire = @cote
        WHERE entite = @entite AND arrete_conclu = @arrete_conclu
          AND cote_questionnaire IS NULL;
    ELSE
        INSERT INTO dbo.maintien_mission
            (entite, arrete_conclu, statut, decision, cote_questionnaire,
             cree_par, cree_le)
        VALUES (@entite, @arrete_conclu, 'OUVERT', 'EN_ATTENTE', @cote, @par,
                SYSUTCDATETIME());
END;

GO

