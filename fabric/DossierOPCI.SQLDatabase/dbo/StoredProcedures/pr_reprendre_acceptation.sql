
-- LE GESTE DU STATUT « REFUSE », que le complement 6 relevait sans geste.
-- Un dossier refuse n'est pas un cul-de-sac : les circonstances changent,
-- et l'article 150 parle d'examen. La reprise exige un motif et remet le
-- dossier a l'etat ouvert, en conservant la trace du refus dans les visas.
CREATE   PROCEDURE dbo.pr_reprendre_acceptation
    @entite  VARCHAR (20),
    @motif   NVARCHAR (800),
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;

    IF @motif IS NULL OR LEN(LTRIM(@motif)) = 0
        THROW 50073,
            N'Reprise refusée : la reprise d''une acceptation refusée exige un motif, qui dit ce qui a changé depuis le refus.',
            1;

    IF NOT EXISTS (SELECT 1 FROM dbo.acceptation_mission
                   WHERE entite = @entite AND statut = 'REFUSE')
        THROW 50073,
            N'Reprise refusée : seule une acceptation au statut refusé se reprend. Un dossier ouvert se répond, un dossier approuvé ne se reprend pas.',
            1;

    UPDATE dbo.acceptation_mission
    SET statut = 'OUVERT', decision = 'EN_ATTENTE',
        reprise_motif = @motif,
        approuve_par = NULL, approuve_le = NULL
    WHERE entite = @entite;
END;

GO

