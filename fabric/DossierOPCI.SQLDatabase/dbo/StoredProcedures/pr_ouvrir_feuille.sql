
-- pr_ouvrir_feuille : 6 refus
CREATE PROCEDURE dbo.pr_ouvrir_feuille
    @cote         VARCHAR (30),
    @modele_code  VARCHAR (20),
    @entite       VARCHAR (20),
    @arrete       VARCHAR (20),
    @cycle        VARCHAR (10) = NULL,
    @phase        VARCHAR (12) = NULL,
    @par          NVARCHAR (200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @m NVARCHAR (2000);

    /* 1 : le modele doit exister au referentiel. */
    IF NOT EXISTS (SELECT 1 FROM dbo.modele_feuille WHERE code = @modele_code)
    BEGIN
        SET @m = N'Ouverture refusée : le modèle ' + ISNULL(@modele_code, N'(vide)') + N' n''existe pas. Choisir un modèle de feuille existant.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50051, @m, 1; END
    END;

    /* 2 : l'arrete doit etre ouvert pour cette entite. Une feuille sans arrete ouvert n'a pas
           de perimetre, et les portes de l'arrete ne l'auraient pas controlee. */
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        SET @m = N'Ouverture refusée : aucun arrêté du ' + @arrete + N' n''est ouvert pour ' + @entite + N'. Ouvrir d''abord cet arrêté, puis la feuille.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50051, @m, 1; END
    END;

    /* 3 : la cote identifie la feuille, elle ne se reprend pas. */
    IF EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
    BEGIN
        SET @m = N'Ouverture refusée : la cote ' + @cote + N' est déjà prise par une autre feuille. Choisir une autre cote, ou ouvrir la feuille existante.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50051, @m, 1; END
    END;

    /* 4 : une feuille appartient a un cycle OU a une phase, jamais aux 2, jamais a aucun.
           La contrainte ck_ft_un_seul_proprietaire de la table le pose ; le refus le dit avant. */
    IF (@cycle IS NULL AND @phase IS NULL) OR (@cycle IS NOT NULL AND @phase IS NOT NULL)
    BEGIN
        SET @m = N'Ouverture refusée : une feuille relève soit d''un cycle de révision, soit d''une phase de la mission. Renseigner le cycle ou la phase, pas les 2.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50051, @m, 1; END
    END;

    /* 5 : le cycle ou la phase doit exister au referentiel. */
    IF @cycle IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_cycle WHERE code = @cycle)
    BEGIN
        SET @m = N'Ouverture refusée : le cycle ' + @cycle + N' n''existe pas. Choisir un cycle de révision existant.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50051, @m, 1; END
    END;
    IF @phase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_phase WHERE code = @phase)
    BEGIN
        SET @m = N'Ouverture refusée : la phase ' + @phase + N' n''existe pas. Choisir une phase existante de la mission.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50051, @m, 1; END
    END;

    /* La feuille attendue : son classeur au site du cabinet, sous le nom que lui donne le depot de
       fn_ecran_revision (feuille_<cote>.xlsx), son chemin vu du coffre, et l'empreinte du gabarit. */
    DECLARE @version VARCHAR (10) = (SELECT version FROM dbo.modele_feuille WHERE code = @modele_code);
    DECLARE @nom VARCHAR (200) = 'feuille_' + @cote + '.xlsx';
    DECLARE @chemin NVARCHAR (800) = dbo.fn_chemin_dossier_de_travail(@entite, @arrete, @nom);
    DECLARE @empreinte CHAR (64) = CONVERT(CHAR (64),
        HASHBYTES('SHA2_256', @cote + '|' + @modele_code + '|' + ISNULL(@version, '')), 2);

    -- L'OBJECTIF DU GABARIT, copie a l'ouverture ; NULL tant qu'il n'est pas redige.
    INSERT INTO dbo.feuille_travail
        (cote, cycle, phase, arrete, entite, modele_code, origine,
         nom_fichier, chemin_coffre, empreinte_sha256, preparateur, prepare_le, objectif)
    VALUES (@cote, @cycle, @phase, @arrete, @entite, @modele_code, 'HUMAINE',
            @nom, @chemin, @empreinte, @par, SYSUTCDATETIME(),
            (SELECT objectif FROM dbo.modele_feuille WHERE code = @modele_code));

    SELECT @cote AS cote, @modele_code AS modele, @nom AS nom_fichier,
           @chemin AS chemin_coffre,
           N'Feuille ouverte avec l''empreinte du gabarit ; le réimport du document la remplacera par celle du fichier.' AS message_ecran;
END;

GO

