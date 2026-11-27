-- pr_journaliser_refus : une ligne de journal_refus, ecrite par la fonction appelante apres son rollback, pour
-- qu'un refus de la base atteigne le reviseur quelle que soit la procedure qui refuse. Une procedure qui leve un
-- THROW voit son INSERT de journal annule par le ROLLBACK de la fonction (fabric.functions ouvre une connexion
-- sans autocommit, et _executer fait conn.rollback() sur l'exception) ; SQL Server n'a pas de transaction
-- autonome : le refus se journalise donc apres le rollback, dans une transaction neuve. Prerequis : journal_refus.

CREATE PROCEDURE dbo.pr_journaliser_refus
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
    -- elle-meme. Une entite absente de ref_entite est ecrite a NULL.
    IF @entite IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.ref_entite WHERE code = @entite)
        SET @entite = NULL;
    INSERT INTO dbo.journal_refus (procedure_nom, entite, cote, message, geste, refuse_pour, refuse_le)
    VALUES (@procedure_nom, @entite, @cote, LEFT(@message, 2000), @geste, @par, SYSUTCDATETIME());
    SELECT SCOPE_IDENTITY() AS id;
END;

GO

