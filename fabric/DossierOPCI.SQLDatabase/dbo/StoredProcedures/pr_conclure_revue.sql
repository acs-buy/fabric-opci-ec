
CREATE   PROCEDURE dbo.pr_conclure_revue
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @conclusion  NVARCHAR (4000),
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50322, N'La revue se conclut sur un arrêté ouvert.', 1;
    IF NULLIF(LTRIM(RTRIM(@conclusion)), N'') IS NULL
        THROW 50323, N'La conclusion générale est un texte.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de conclure à nouveau.', 1;
    IF EXISTS (SELECT 1 FROM dbo.conclusion_revue WHERE entite = @entite AND arrete = @arrete)
        UPDATE dbo.conclusion_revue SET conclusion = @conclusion, conclu_par = @par, conclu_le = SYSUTCDATETIME()
         WHERE entite = @entite AND arrete = @arrete;
    ELSE
        INSERT INTO dbo.conclusion_revue (entite, arrete, conclusion, conclu_par) VALUES (@entite, @arrete, @conclusion, @par);
    DECLARE @cycles INT = (SELECT COUNT(DISTINCT q.cycle) FROM dbo.programme_travail p JOIN dbo.programme_question pq ON pq.programme_id = p.id AND pq.actif = 1
                           JOIN dbo.ref_question q ON q.id = pq.question_id WHERE p.entite = @entite AND p.arrete = @arrete);
    DECLARE @conclus INT = (SELECT COUNT(*) FROM dbo.conclusion_cycle WHERE entite = @entite AND arrete = @arrete);
    SELECT @conclus AS cycles_conclus, @cycles AS cycles_du_programme,
           N'Revue conclue : ' + CAST(@conclus AS NVARCHAR (10)) + N' cycle(s) conclu(s) sur ' + CAST(@cycles AS NVARCHAR (10)) + N' au programme.' AS message;
END;

GO

