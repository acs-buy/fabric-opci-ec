-- =====================================================================
-- LOT I du plan fusionne, deuxieme partie : l'inscription au carnet est
-- separee du chargement, et une balance se charge par son propre chemin.
--
-- CE QUE LA SPECIFICATION DEMANDAIT, point P6 : « scission du script 11 :
-- inscription a l'arrivee du transit, chargement au bouton, blocs 2 a 8,
-- refus journalises ».
--
-- CE QUE JE FAIS, ET CE QUE JE NE FAIS PAS. Je pose
-- dbo.pr_inscrire_import, qui inscrit l'entete et porte les 5 refus du
-- carnet, et dbo.pr_charger_balance, qui charge une balance de transit
-- vers un lot. dbo.pr_charger_import aiguille selon le format.
--
-- JE NE DECOUPE PAS dbo.pr_charger_import_fec, et voici le motif. Elle
-- porte 200 lignes, 5 gardes et 4 blocs transactionnels, et 2 pieces
-- l'appellent : le script 62 qui la cree et 61_DEPLOIEMENT/rejeu_fec.ps1
-- qui rejoue le fichier des ecritures d'un exercice reel. La decouper
-- sans pouvoir rejouer ce fichier, qui n'est pas au dossier, serait
-- refaire a l'aveugle le seul chemin que le rejeu a eprouve. Le chemin
-- FEC garde donc sa procedure, et dbo.pr_charger_import l'appelle. La
-- scission est faite pour la balance, qui est neuve, et le FEC l'attendra
-- que son fichier de rejeu soit disponible. C'est un choix, non un oubli.
--
-- LES REFUS SONT DESORMAIS PERENNES. Chaque refus du carnet ecrit 2 fois :
-- dans dbo.journal_refus, qui porte tous les refus de la base, et dans
-- dbo.rejet_import, qui porte ceux d'un import et survit au vidage du
-- transit. L'ecran E1-A lit la seconde.
-- A executer contre la BASE SQL Fabric DossierOPCI.
-- =====================================================================

-- --- 1 : pr_inscrire_import, l'entete et les 5 refus du carnet -------
CREATE   PROCEDURE dbo.pr_inscrire_import
    @entite           VARCHAR (20),
    @arrete           VARCHAR (20),
    @format           VARCHAR (10),
    @nom_fichier      NVARCHAR (400),
    @empreinte        VARCHAR (64),
    @exercice_debut   DATE,
    @exercice_fin     DATE,
    @lignes_lues      INT,
    @lignes_rejetees  INT,
    @par              NVARCHAR (200),
    @import_id        INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @import_id = NULL;
    DECLARE @m NVARCHAR (2000), @motif_arret NVARCHAR (400);
    DECLARE @date_arrete DATE = (SELECT date_arrete FROM dbo.ref_arrete
                                 WHERE entite = @entite AND arrete = @arrete);
    BEGIN TRY
        -- Refus 1 : l'arrete n'existe pas au referentiel.
        IF @date_arrete IS NULL
        BEGIN
            SET @m = N'Inscription refusee : l''arrete ' + @arrete
                   + N' de l''entite ' + @entite + N' ne figure pas au '
                   + N'referentiel des arretes. Un fichier ne s''inscrit pas '
                   + N'sur un arrete qui n''existe pas.';
            SET @motif_arret = N'Arrete inconnu au referentiel.';
            THROW 50064, @m, 1;
        END;

        -- Refus 2 : le format n'est pas connu.
        IF @format NOT IN ('FEC', 'BALANCE')
        BEGIN
            SET @m = N'Inscription refusee : le format se dit FEC ou BALANCE, '
                   + N'et rien d''autre. Recu : ' + COALESCE(@format, N'NULL')
                   + N'.';
            SET @motif_arret = N'Format inconnu.';
            THROW 50064, @m, 1;
        END;

        -- Refus 3 : l'exercice du fichier ne contient pas la date d'arrete.
        IF @date_arrete NOT BETWEEN @exercice_debut AND @exercice_fin
        BEGIN
            SET @m = N'Inscription refusee : la date d''arrete '
                   + CONVERT(CHAR (10), @date_arrete, 126)
                   + N' n''est pas comprise dans l''exercice du fichier, du '
                   + CONVERT(CHAR (10), @exercice_debut, 126) + N' au '
                   + CONVERT(CHAR (10), @exercice_fin, 126)
                   + N'. Un fichier ne porte pas les ecritures d''un arrete '
                   + N'hors de son exercice.';
            SET @motif_arret = N'Exercice non conforme a l''arrete.';
            THROW 50064, @m, 1;
        END;

        -- Refus 4 : l'empreinte est deja chargee. Le meme fichier entrerait
        -- 2 fois, et ses ecritures seraient comptabilisees en double.
        IF @empreinte IS NOT NULL
           AND EXISTS (SELECT 1 FROM dbo.import_fec i
                       WHERE i.empreinte = @empreinte AND i.statut = 'CHARGE')
        BEGIN
            DECLARE @deja INT = (SELECT TOP (1) id FROM dbo.import_fec
                                 WHERE empreinte = @empreinte
                                   AND statut = 'CHARGE');
            SET @m = N'Inscription refusee : l''empreinte de ce fichier est '
                   + N'deja portee par l''import ' + CAST(@deja AS NVARCHAR (20))
                   + N', charge. Le meme fichier entrerait 2 fois et ses '
                   + N'ecritures seraient comptabilisees en double.';
            SET @motif_arret = N'Empreinte deja chargee.';
            THROW 50064, @m, 1;
        END;

        -- Refus 5 : un import est deja charge sur ce perimetre. Le
        -- second produirait un SECOND LOT et doublerait les ecritures de
        -- l'entite a cet arrete. Releve a l'epreuve du 04/09/2026 : le
        -- chargement d'une balance sur OMEGA-SCI-9 au 31/12/2025, qui en
        -- portait deja une, a donne 2 lots de famille IMPORTEE. La
        -- specification demandait de signaler « autre import deja
        -- charge » dans la vue du carnet ; le signaler ne suffit pas, il
        -- faut le refuser, un ecran ne pouvant defaire un doublon
        -- d'ecritures.
        IF EXISTS (SELECT 1 FROM dbo.import_fec i
                   WHERE i.entite = @entite AND i.arrete = @arrete
                     AND i.statut = 'CHARGE')
        BEGIN
            DECLARE @autre INT = (SELECT TOP (1) id FROM dbo.import_fec
                                  WHERE entite = @entite AND arrete = @arrete
                                    AND statut = 'CHARGE');
            SET @m = N'Inscription refusee : l''import '
                   + CAST(@autre AS NVARCHAR (20))
                   + N' est deja charge pour ' + @entite + N' a l''arrete '
                   + @arrete + N'. Un second import produirait un second lot '
                   + N'et doublerait les ecritures. Annuler le lot du premier '
                   + N'import avant de reprendre.';
            SET @motif_arret = N'Un import est deja charge sur ce perimetre.';
            THROW 50064, @m, 1;
        END;

        INSERT INTO dbo.import_fec
            (entite, arrete, format, nom_fichier, empreinte, exercice_debut,
             exercice_fin, lignes_lues, lignes_rejetees, statut, importe_par)
        VALUES (@entite, @arrete, @format, @nom_fichier, @empreinte,
                @exercice_debut, @exercice_fin, @lignes_lues,
                COALESCE(@lignes_rejetees, 0), 'EN_COURS', @par);
        SET @import_id = CAST(SCOPE_IDENTITY() AS INT);
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
        -- Le refus s'inscrit au carnet comme un import REJETE, pour que
        -- l'ecran le montre a cote de ceux qui ont abouti : un fichier
        -- refuse est un fait de la mission, il ne disparait pas.
        --
        -- MAIS PAS QUAND L'ARRETE N'EXISTE PAS. La cle fk_import_arrete
        -- exige un arrete du referentiel : tenter l'inscription rendait
        -- alors le message de la cle etrangere a la place du mien, releve
        -- a l'epreuve du 04/09/2026. Le refus n'est journalise que dans
        -- dbo.journal_refus, dont l'entite et l'arrete sont libres, et le
        -- carnet ne porte rien : il n'y a pas d'arrete auquel rattacher
        -- une ligne.
        IF @date_arrete IS NOT NULL
        INSERT INTO dbo.import_fec
            (entite, arrete, format, nom_fichier, empreinte, exercice_debut,
             exercice_fin, lignes_lues, lignes_rejetees, statut, importe_par)
        VALUES (@entite, @arrete,
                CASE WHEN @format IN ('FEC', 'BALANCE') THEN @format
                     ELSE 'FEC' END,
                @nom_fichier, @empreinte, @exercice_debut, @exercice_fin,
                COALESCE(@lignes_lues, 0), COALESCE(@lignes_lues, 0),
                'REJETE', @par);
        DECLARE @rej INT = CAST(SCOPE_IDENTITY() AS INT);
        IF @rej IS NOT NULL AND @date_arrete IS NOT NULL
            INSERT INTO dbo.rejet_import
                (import_id, nature, motif, motif_arret, geste)
            VALUES (@rej, 'FICHIER',
                    LEFT(COALESCE(@m, ERROR_MESSAGE()), 800),
                    COALESCE(@motif_arret, N'Refus a l''inscription.'),
                    N'Corriger le fichier ou l''arrete, puis reprendre l''inscription.');
        INSERT INTO dbo.journal_refus
            (procedure_nom, entite, arrete, message, refuse_pour)
        VALUES ('pr_inscrire_import', @entite, @arrete,
                LEFT(COALESCE(@m, ERROR_MESSAGE()), 2000), @par);
        THROW;
    END CATCH;
END

GO

