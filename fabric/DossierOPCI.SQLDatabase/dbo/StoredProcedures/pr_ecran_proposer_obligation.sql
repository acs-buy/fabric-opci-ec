
-- ------------------------------------------------------------------ n° 4 : proposer la base d'une categorie
-- 4 refus avant toute ecriture, dans cet ordre : champ vide (nomme) ; @par sans le role PREPARATEUR du vehicule ;
-- arrete qui n'est pas un arrete annuel ouvert du vehicule ; categorie deja visee. A l'ecriture, le declencheur 50086
-- (tr_obligation_proposant_distinct) garde le publiant de la VL.
CREATE   PROCEDURE dbo.pr_ecran_proposer_obligation
    @entite    VARCHAR (20),
    @arrete    VARCHAR (20),
    @categorie NVARCHAR (300),
    @base      DECIMAL (19,2),
    @source    NVARCHAR (400),
    @par       NVARCHAR (400)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (1000);
    SET @categorie = NULLIF(LTRIM(RTRIM(@categorie)), N'');
    SET @source = NULLIF(LTRIM(RTRIM(@source)), N'');
    IF @categorie IS NULL
        THROW 50810, N'Choisissez la catégorie dans la liste « Catégorie ».', 1;
    IF @base IS NULL
        THROW 50811, N'La base de calcul est obligatoire.', 1;
    IF @source IS NULL
        THROW 50812, N'La source de la base est obligatoire : elle dit d''où vient le montant.', 1;
    DECLARE @cat VARCHAR (20) = dbo.fn_e4_categorie(@categorie);
    IF @cat IS NULL
    BEGIN
        SET @m = N'La catégorie « ' + REPLACE(@categorie, N'%', N'%%') + N' » n''est pas une catégorie de l''obligation de distribution.';
        THROW 50813, @m, 1;
    END;
    IF dbo.fn_e4_tient_role(@entite, 'PREPARATEUR', @par) = 0
        THROW 50814, N'Proposition refusée : la base se propose par le préparateur du dossier, rôle que votre adresse de connexion ne tient pas.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete AND type_arrete = 'ANNUEL')
        THROW 50815, N'Proposition refusée : l''obligation de distribution se calcule à la clôture annuelle, et cet arrêté n''est pas un arrêté annuel ouvert du véhicule.', 1;
    IF EXISTS (SELECT 1 FROM dbo.obligation_distribution WHERE entite = @entite AND exercice = @arrete AND categorie = @cat AND etat = 'VISEE')
        THROW 50816, N'Proposition refusée : cette catégorie est déjà visée pour l''exercice.', 1;
    DECLARE @taux DECIMAL (5,2) = CASE @cat WHEN 'REVENUS_85' THEN 85 WHEN 'PLUS_VALUES_50' THEN 50 ELSE 100 END;
    DECLARE @montant DECIMAL (19,2) = ROUND(@base * @taux / 100, 2);
    UPDATE dbo.obligation_distribution
       SET base_calcul = @base, taux = @taux, montant = @montant, source = @source, etat = 'PROPOSEE',
           propose_par = @par, vise_par = NULL, vise_le = NULL
     WHERE entite = @entite AND exercice = @arrete AND categorie = @cat;
    IF @@ROWCOUNT = 0
        INSERT INTO dbo.obligation_distribution (entite, exercice, categorie, base_calcul, taux, montant, dont_indirect_n_moins_1,
                                                 source, vise_par, vise_le, etat, propose_par)
        VALUES (@entite, @arrete, @cat, @base, @taux, @montant, 0, @source, NULL, NULL, 'PROPOSEE', @par);
    SELECT @entite AS vehicule,
           N'Base proposée : ' + dbo.fn_e3_montant(@base) + N' × ' + CAST(CAST(@taux AS INT) AS NVARCHAR (4)) + N' % = '
           + dbo.fn_e3_montant(@montant) + N'. Elle attend le visa de l''associé.' AS message;
END;

GO

