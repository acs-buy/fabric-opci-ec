-- 220. Un refus de la base atteint le reviseur, quelle que soit la procedure qui refuse.
--
-- DEFAUT MESURE PAR FABRIC IQ LE 21/09/2026 : au temps 2, ajouter une filiale deja au perimetre ne
-- produit RIEN a l'ecran. La base refuse bien (50214), la base ne change pas, et le reviseur ne lit
-- aucun message. Le canal n'est pas casse, IL N'EXISTE PAS pour ces procedures : le pied du panneau lit
-- une colonne message_ecran de acceptation_mission, table qu'une procedure de filiale n'ecrit jamais.
--
-- POURQUOI LA BASE NE PEUT PAS S'EN CHARGER SEULE, et c'est le point technique : une procedure qui leve
-- un THROW voit son INSERT de journal annule par le ROLLBACK de la fonction appelante (fabric.functions
-- ouvre une connexion sans autocommit, et _executer fait conn.rollback() sur l'exception). SQL Server n'a
-- pas de transaction autonome. Le refus se journalise donc APRES le rollback, par la FONCTION, qui
-- appelle pr_journaliser_refus dans une transaction neuve. C'est le script 220 cote base, et la
-- modification de _executer cote fonction.
--
-- Ce que ce script pose :
--   1. pr_journaliser_refus : une ligne de journal_refus, appelee par la fonction apres rollback ;
--   2. v_ecran_message : le DERNIER message destine a une personne, par entite, avec son anciennete.
--      L'ecran le lit par une mesure filtree sur l'utilisateur connecte et sur le client courant.
-- Prerequis : journal_refus. Rejouable.

CREATE   PROCEDURE dbo.pr_journaliser_refus
    @procedure_nom  VARCHAR (128),
    @message        NVARCHAR (2000),
    @par            NVARCHAR (400),
    @entite         VARCHAR (20)   = NULL,
    @cote           VARCHAR (30)   = NULL,
    @geste          NVARCHAR (400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    -- aucun controle bloquant : cette procedure sert a RAPPORTER un refus, elle ne doit jamais refuser
    -- a son tour. Une entite inconnue est donc ecrite telle quelle si la cle etrangere l'admet, sinon nulle.
    IF @entite IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        SET @entite = NULL;
    INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
    VALUES (@procedure_nom, @entite, @cote, LEFT(@message, 2000), @geste, @par, SYSUTCDATETIME());
    SELECT SCOPE_IDENTITY() AS id;
END;

GO

