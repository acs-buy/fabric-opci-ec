CREATE TABLE [dbo].[rejet_import] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [import_id]    INT             NOT NULL,
    [nature]       VARCHAR (20)    NOT NULL,
    [numero_ligne] INT             NULL,
    [compte_num]   VARCHAR (20)    NULL,
    [debit]        DECIMAL (19, 2) NULL,
    [credit]       DECIMAL (19, 2) NULL,
    [motif]        NVARCHAR (800)  NOT NULL,
    [geste]        NVARCHAR (400)  NULL,
    [motif_arret]  NVARCHAR (400)  NULL,
    [rejete_le]    DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_rejet_import] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_rejet_arret_motive] CHECK ([nature]<>'FICHIER' OR [motif_arret] IS NOT NULL),
    CONSTRAINT [ck_rejet_ligne_numerotee] CHECK ([nature]='LIGNE' AND [numero_ligne] IS NOT NULL OR [nature]<>'LIGNE' AND [numero_ligne] IS NULL),
    CONSTRAINT [ck_rejet_nature] CHECK ([nature]='COMPTE' OR [nature]='CARNET' OR [nature]='FICHIER' OR [nature]='LIGNE'),
    CONSTRAINT [fk_rejet_import] FOREIGN KEY ([import_id]) REFERENCES [dbo].[import_fec] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_rejet_import]
    ON [dbo].[rejet_import]([import_id] ASC, [nature] ASC);


GO

