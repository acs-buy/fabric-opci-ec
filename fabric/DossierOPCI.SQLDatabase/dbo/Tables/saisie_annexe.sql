CREATE TABLE [dbo].[saisie_annexe] (
    [id]        INT             IDENTITY (1, 1) NOT NULL,
    [entite]    VARCHAR (20)    NOT NULL,
    [arrete]    VARCHAR (20)    NOT NULL,
    [article]   VARCHAR (10)    NOT NULL,
    [ligne]     NVARCHAR (300)  NOT NULL,
    [colonne]   NVARCHAR (120)  NOT NULL,
    [valeur]    NVARCHAR (2000) NULL,
    [montant]   DECIMAL (19, 6) NULL,
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


CREATE   TRIGGER dbo.tr_saisie_annexe_annexe_retard ON dbo.saisie_annexe
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, arrete, article, colonne, entite, ligne, montant, motif, saisi_le, valeur FROM inserted
        EXCEPT SELECT id, arrete, article, colonne, entite, ligne, montant, motif, saisi_le, valeur FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, arrete, article, colonne, entite, ligne, montant, motif, saisi_le, valeur FROM deleted EXCEPT SELECT id, arrete, article, colonne, entite, ligne, montant, motif, saisi_le, valeur FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'saisie_annexe', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO


-- tr_saisie_annexe_garde : 1 refus
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
        BEGIN SET @m = REPLACE(@m, N'%', N'%%'); THROW 50074, @m, 1; END
    END;
END;

GO

