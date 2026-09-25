
CREATE   PROCEDURE dbo.pr_deverrouiller_dossier
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20),
    @par     NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @qui NVARCHAR (400) = (SELECT verrouille_par FROM dbo.dossier_verrou WHERE entite = @entite AND arrete = @arrete AND verrouille = 1);
    IF @qui IS NULL
        THROW 50351, N'Le dossier de cet arrêté n''est pas verrouillé.', 1;
    IF @qui <> @par
    BEGIN
        DECLARE @m NVARCHAR (600) = N'Seule la personne qui a visé la revue déverrouille le dossier : ' + @qui + N'.';
        THROW 50352, @m, 1;
    END;
    UPDATE dbo.dossier_verrou SET verrouille = 0, deverrouille_par = @par, deverrouille_le = SYSUTCDATETIME()
     WHERE entite = @entite AND arrete = @arrete;
    SELECT N'Dossier de l''arrêté ' + @arrete + N' déverrouillé : tout utilisateur peut réimporter.' AS message;
END;

GO

