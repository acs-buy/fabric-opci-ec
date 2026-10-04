CREATE TABLE [dbo].[saisie_annexe] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [entite]    VARCHAR (20)    NOT NULL,
    [arrete]    VARCHAR (20)    NOT NULL,
    [article]   VARCHAR (10)    NOT NULL,
    [ligne]     NVARCHAR (300)  NOT NULL,
    [colonne]   NVARCHAR (120)  NOT NULL,
    [valeur]    NVARCHAR (2000) NULL,
    [montant]   DECIMAL (19, 2) NULL,
    [saisi_par] NVARCHAR (400)  NOT NULL,
    [saisi_le]  DATETIME2 (3)   NOT NULL,
    [motif]     NVARCHAR (800)  NULL,
    [motif_par] NVARCHAR (400)  NULL,
    [motif_le]  DATETIME2 (3)   NULL,
    CONSTRAINT [pk_saisie_annexe] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_saisie_annexe_motif] CHECK ([motif] IS NULL OR [motif_par] IS NOT NULL AND [motif_le] IS NOT NULL),
    CONSTRAINT [ck_saisie_annexe_valeur] CHECK ([valeur] IS NOT NULL AND [montant] IS NULL OR [valeur] IS NULL AND [montant] IS NOT NULL),
    CONSTRAINT [fk_saisie_annexe_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_saisie_annexe_article] FOREIGN KEY ([article]) REFERENCES [dbo].[ref_article] ([article]),
    CONSTRAINT [uq_saisie_annexe] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [article] ASC, [ligne] ASC, [colonne] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_saisie_annexe]
    ON [dbo].[saisie_annexe]([entite] ASC, [arrete] ASC, [article] ASC);


GO

-- 4. LE FILET DE L'ECRITURE DIRECTE. La procedure pose le contexte saisie_annexe_par le temps de son ecriture ; hors
-- d'elle, chaque ligne ecrite est jugee sur son entite et sur le compte connecte.
CREATE   TRIGGER dbo.tr_saisie_annexe_garde
ON dbo.saisie_annexe
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF TRY_CAST(SESSION_CONTEXT(N'semis') AS INT) = 1 RETURN;
    IF SESSION_CONTEXT(N'saisie_annexe_par') IS NOT NULL RETURN;
    DECLARE @qui NVARCHAR (400) = SUSER_SNAME(), @le DATE = CAST(SYSUTCDATETIME() AS DATE), @entite VARCHAR (20), @m NVARCHAR (600);
    SELECT TOP (1) @entite = x.entite
    FROM (SELECT entite FROM inserted UNION SELECT entite FROM deleted) x
    WHERE dbo.fn_peut_saisir_annexe(x.entite, @qui, @le) = 0;
    IF @entite IS NOT NULL
    BEGIN
        SET @m = N'Écriture refusée : une cellule d''annexe de l''entité ' + @entite
               + N' ne s''écrit que par une personne qui tient un rôle de mission sur cette entité. Passer par la saisie de l''écran.';
        THROW 50074, @m, 1;
    END;
END;

GO

