
CREATE   PROCEDURE dbo.pr_conclure_cycle
    @entite      VARCHAR (20),
    @arrete      VARCHAR (20),
    @cycle       VARCHAR (10),
    @conclusion  NVARCHAR (2000),
    @forme       VARCHAR (20)   = NULL,
    @par         NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_cycle WHERE code = @cycle)
        THROW 50321, N'Le cycle désigné n''existe pas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
        THROW 50322, N'Un cycle se conclut sur un arrêté ouvert.', 1;
    IF NULLIF(LTRIM(RTRIM(@conclusion)), N'') IS NULL
        THROW 50323, N'La conclusion du cycle est un texte : ce qui a été vu de bloquant, ce qui a été vu de satisfaisant.', 1;
    IF dbo.fn_dossier_verrouille(@entite, @arrete) = 1
        THROW 50303, N'Le dossier de cet arrêté est visé et verrouillé ; le déverrouiller avant de conclure à nouveau.', 1;
    IF EXISTS (SELECT 1 FROM dbo.visa WHERE nature = 'CYCLE' AND entite = @entite AND arrete = @arrete AND cycle = @cycle AND decision = 'VISE')
        THROW 50324, N'Ce cycle est déjà visé ; sa conclusion ne se modifie plus.', 1;

    DECLARE @synthese NVARCHAR (MAX) = dbo.fn_synthese_feuilles(@entite, @arrete, @cycle);
    IF EXISTS (SELECT 1 FROM dbo.conclusion_cycle WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle)
        UPDATE dbo.conclusion_cycle
           SET synthese_feuilles = @synthese, conclusion = @conclusion, forme = @forme, conclu_par = @par, conclu_le = SYSUTCDATETIME()
         WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle;
    ELSE
        INSERT INTO dbo.conclusion_cycle (entite, arrete, cycle, synthese_feuilles, conclusion, forme, conclu_par)
        VALUES (@entite, @arrete, @cycle, @synthese, @conclusion, @forme, @par);

    DECLARE @n INT = (SELECT COUNT(*) FROM dbo.feuille_travail WHERE entite = @entite AND arrete = @arrete AND cycle = @cycle AND cote NOT LIKE 'Q-%');
    SELECT @cycle AS cycle, @n AS feuilles, @synthese AS synthese_feuilles,
           N'Cycle ' + @cycle + N' conclu, synthèse de ' + CAST(@n AS NVARCHAR (10)) + N' feuille(s) régénérée. Le visa du chef de mission peut être demandé.' AS message;
END;

GO

