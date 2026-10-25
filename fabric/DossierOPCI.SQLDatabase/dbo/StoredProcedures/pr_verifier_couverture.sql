
CREATE   PROCEDURE dbo.pr_verifier_couverture
    @entite  VARCHAR (20),
    @arrete  VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51201, N'Choisissez le véhicule dans le sélecteur Véhicule.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51202, N'Choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    -- 327 fin
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

