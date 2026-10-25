
-- pr_garde_generer_lot_valorisation : 1 refus
-- ------------------------------------------------------------------ n° 25 : la garde de la generation du lot
-- Appelee par fn_valorisation.generer_lot_valorisation dans sa transaction, avant d'ecrire la feuille et le lot : les
-- verrous d'entite des vehicules touches, puis un verrou d'application sur l'entite et l'arrete, tenus jusqu'au commit de
-- l'appelant ; les 3 gardes de pr_demander_reevaluation relues sous le verrou. Un 2e appel attend le commit du 1er, puis
-- est refuse par la 2e garde.
CREATE   PROCEDURE dbo.pr_garde_generer_lot_valorisation
    @entite VARCHAR (20),
    @arrete VARCHAR (20)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    -- 327 debut (24/10/2026) : un champ vide se refuse en francais avant toute ecriture, au texte du champ dans le
    -- plan de l'etude des fonctions (decision A du candidat). Genere par 61_DEPLOIEMENT/generer_327_refus_champs_vides.py.
    -- le vide : les 29 caracteres de str.isspace(), compares au point de code
    DECLARE @r327_blancs NVARCHAR (29) = NCHAR(9) + NCHAR(10) + NCHAR(11) + NCHAR(12) + NCHAR(13) + NCHAR(28) + NCHAR(29) + NCHAR(30) + NCHAR(31) + NCHAR(32)
        + NCHAR(133) + NCHAR(160) + NCHAR(5760) + NCHAR(8192) + NCHAR(8193) + NCHAR(8194) + NCHAR(8195) + NCHAR(8196) + NCHAR(8197) + NCHAR(8198)
        + NCHAR(8199) + NCHAR(8200) + NCHAR(8201) + NCHAR(8202) + NCHAR(8232) + NCHAR(8233) + NCHAR(8239) + NCHAR(8287) + NCHAR(12288);
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @arrete COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51227, N'Génération refusée : choisissez l''arrêté dans le sélecteur Arrêté.', 1;
    IF ISNULL(DATALENGTH(TRIM(@r327_blancs COLLATE Latin1_General_100_BIN2 FROM @entite COLLATE Latin1_General_100_BIN2)), 0) = 0
        THROW 51226, N'Génération refusée : pour le véhicule du sélecteur Véhicule, le lot ne se génère pas en l''état (expertise sans rapport rattaché, demande de réévaluation en attente, lot dérivable proposé non périmé, ou aucun actif calculable).', 1;
    -- 327 fin
    IF @@TRANCOUNT = 0
        THROW 50795, N'La garde de la génération se prend dans la transaction de la génération : aucune transaction n''est ouverte.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.ref_arrete WHERE entite = @entite AND arrete = @arrete)
        THROW 50061, N'Génération refusée : cet arrêté n''existe pas au référentiel pour cette entité.', 1;
    EXEC dbo.pr_e3_verrouiller @entite = @entite;
    DECLARE @res NVARCHAR (255) = N'valorisation:' + CAST(@entite AS NVARCHAR (20)) + N'|' + CAST(@arrete AS NVARCHAR (20)), @rc INT;
    EXEC @rc = sp_getapplock @Resource = @res, @LockMode = 'Exclusive', @LockOwner = 'Transaction', @LockTimeout = 120000;
    IF @rc < 0
        THROW 50061, N'Génération refusée : une autre génération est en cours pour cette entité à cet arrêté ; réessayez dans un instant.', 1;
    IF EXISTS (SELECT 1 FROM dbo.demande_reevaluation WHERE entite = @entite AND arrete = @arrete AND etat = 'EN_ATTENTE')
        THROW 50061, N'Génération refusée : une demande de réévaluation est en attente pour cette entité à cet arrêté.', 1;
    DECLARE @lot INT = (SELECT TOP (1) id FROM dbo.lot_ecritures
                        WHERE entite = @entite AND arrete = @arrete AND statut = 'PROPOSE' AND famille = 'DERIVABLE' AND perime_le IS NULL);
    IF @lot IS NOT NULL
    BEGIN
        DECLARE @m NVARCHAR (2000) = N'Génération refusée : le lot ' + CAST(@lot AS NVARCHAR (20))
            + N' est proposé et non périmé pour cette entité à cet arrêté. Le viser, le renvoyer ou l''annuler avant de générer de nouveau.';
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50061, @m, 1; END
    END;
    IF NOT EXISTS (SELECT 1 FROM dbo.v_a_generer WHERE entite = @entite AND arrete = @arrete AND etat_generation = 'CALCULABLE')
        THROW 50061, N'Génération refusée : aucun actif n''est calculable à cet arrêté. L''état de chaque actif se lit à l''étape 1.', 1;
END;

GO

