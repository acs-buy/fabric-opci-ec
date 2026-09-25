
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
        SET @m = N'Ouverture refusee : le modele ' + ISNULL(@modele_code, N'(vide)')
               + N' est inconnu du referentiel des modeles de feuille. Choisir un des modeles '
               + N'en vigueur, ou l''ajouter au referentiel avant d''ouvrir la feuille.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        THROW 50051, @m, 1;
    END;

    /* 2 : l'arrete doit etre ouvert pour cette entite. Une feuille sans arrete ouvert n'a pas
           de perimetre, et les portes de l'arrete ne l'auraient pas controlee. */
    IF NOT EXISTS (SELECT 1 FROM dbo.arrete_mission WHERE entite = @entite AND arrete = @arrete)
    BEGIN
        SET @m = N'Ouverture refusee : aucun arrete du ' + @arrete + N' n''est ouvert pour '
               + @entite + N'. Ouvrir l''arrete par pr_ouvrir_arrete, dont les portes exigent '
               + N'notamment une expertise a la date de l''arrete pour les actifs qui s''evaluent '
               + N'a la valeur actuelle, article 211-6.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        THROW 50051, @m, 1;
    END;

    /* 3 : la cote identifie la feuille, elle ne se reprend pas. */
    IF EXISTS (SELECT 1 FROM dbo.feuille_travail WHERE cote = @cote)
    BEGIN
        SET @m = N'Ouverture refusee : la cote ' + @cote + N' est deja prise. Une cote identifie '
               + N'une feuille et une seule : en choisir une autre, ou ouvrir la feuille existante.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        THROW 50051, @m, 1;
    END;

    /* 4 : une feuille appartient a un cycle OU a une phase, jamais aux 2, jamais a aucun.
           La contrainte ck_ft_un_seul_proprietaire de la table le pose ; le refus le dit avant. */
    IF (@cycle IS NULL AND @phase IS NULL) OR (@cycle IS NOT NULL AND @phase IS NOT NULL)
    BEGIN
        SET @m = N'Ouverture refusee : une feuille appartient a un cycle de revision OU a une '
               + N'phase de la mission, jamais aux 2 et jamais a aucun. Renseigner exactement '
               + N'un des 2.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        THROW 50051, @m, 1;
    END;

    /* 5 : le cycle ou la phase doit exister au referentiel. */
    IF @cycle IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_cycle WHERE code = @cycle)
    BEGIN
        SET @m = N'Ouverture refusee : le cycle ' + @cycle + N' est inconnu du referentiel des '
               + N'cycles de revision.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        THROW 50051, @m, 1;
    END;
    IF @phase IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_phase WHERE code = @phase)
    BEGIN
        SET @m = N'Ouverture refusee : la phase ' + @phase + N' est inconnue du referentiel des '
               + N'phases de la mission.';
        INSERT INTO dbo.journal_refus (procedure_nom, entite, arrete, cote, message, refuse_pour)
        VALUES ('pr_ouvrir_feuille', @entite, @arrete, @cote, @m, @par);
        THROW 50051, @m, 1;
    END;

    /* La feuille attendue : nom, chemin et empreinte du gabarit. */
    DECLARE @version VARCHAR (10) = (SELECT version FROM dbo.modele_feuille WHERE code = @modele_code);
    DECLARE @nom VARCHAR (200) = @cote + '_' + LOWER(@modele_code) + '_' + @arrete + '.xlsx';
    DECLARE @chemin VARCHAR (400) = '/Coffre/' + @entite + '/' + @arrete + '/feuilles/' + @nom;
    DECLARE @empreinte CHAR (64) = CONVERT(CHAR (64),
        HASHBYTES('SHA2_256', @cote + '|' + @modele_code + '|' + ISNULL(@version, '')), 2);

    INSERT INTO dbo.feuille_travail
        (cote, cycle, phase, arrete, entite, modele_code, origine,
         nom_fichier, chemin_coffre, empreinte_sha256, preparateur, prepare_le)
    VALUES (@cote, @cycle, @phase, @arrete, @entite, @modele_code, 'HUMAINE',
            @nom, @chemin, @empreinte, @par, SYSUTCDATETIME());

    SELECT @cote AS cote, @modele_code AS modele, @nom AS nom_fichier,
           @chemin AS chemin_coffre,
           N'Feuille ouverte. L''empreinte posee est celle du gabarit : deposer le document au '
         + N'coffre la remplacera par celle du fichier.' AS message_ecran;
END;

GO

