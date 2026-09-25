
CREATE   PROCEDURE dbo.pr_verifier_couverture
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @comptes INT, @couverts INT, @non INT, @sans INT, @liste NVARCHAR (1000);
    SELECT @comptes = COUNT(*),
           @couverts = SUM(CASE WHEN etat = 'COUVERT' THEN 1 ELSE 0 END),
           @non = SUM(CASE WHEN etat = 'NON_COUVERT' THEN 1 ELSE 0 END),
           @sans = SUM(CASE WHEN etat = 'SANS_CYCLE' THEN 1 ELSE 0 END)
    FROM dbo.v_couverture_balance WHERE entite = @entite AND arrete = @arrete;
    SELECT @liste = STRING_AGG(CAST(compte AS NVARCHAR (20)), N', ') FROM dbo.v_couverture_balance
    WHERE entite = @entite AND arrete = @arrete AND etat IN ('NON_COUVERT', 'SANS_CYCLE');
    SELECT ISNULL(@comptes, 0) AS comptes, ISNULL(@couverts, 0) AS couverts, ISNULL(@non, 0) AS non_couverts, ISNULL(@sans, 0) AS sans_cycle,
           CASE WHEN ISNULL(@comptes, 0) = 0 THEN N'Aucun compte en balance pour cet arrêté : rien à couvrir.'
                WHEN ISNULL(@non, 0) + ISNULL(@sans, 0) = 0 THEN N'La balance est couverte : ' + CAST(@comptes AS NVARCHAR (10)) + N' comptes, tous revus par une question du programme.'
                ELSE CAST(ISNULL(@non, 0) + ISNULL(@sans, 0) AS NVARCHAR (10)) + N' compte(s) sur ' + CAST(@comptes AS NVARCHAR (10))
                   + N' hors du programme : ' + ISNULL(@liste, N'') + N'. Ajouter une question qui les revoit, ou compléter les racines des cycles aux Référentiels.' END AS message;
END;

GO

