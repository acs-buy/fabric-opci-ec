CREATE TABLE [dbo].[demande_reouverture] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [entite]      VARCHAR (20)   NOT NULL,
    [arrete]      VARCHAR (20)   NOT NULL,
    [nature]      VARCHAR (14)   CONSTRAINT [df_demande_reouverture_nature] DEFAULT ('REOUVERTURE') NOT NULL,
    [motif]       NVARCHAR (800) NOT NULL,
    [demande_par] NVARCHAR (400) NOT NULL,
    [demande_le]  DATETIME2 (3)  CONSTRAINT [df_demande_reouverture_demande_le] DEFAULT (sysutcdatetime()) NOT NULL,
    [etat]        VARCHAR (12)   CONSTRAINT [df_demande_reouverture_etat] DEFAULT ('EN_ATTENTE') NOT NULL,
    [decide_par]  NVARCHAR (400) NULL,
    [decide_le]   DATETIME2 (3)  NULL,
    [motif_ecart] NVARCHAR (800) NULL,
    [visa_id]     INT            NULL,
    CONSTRAINT [pk_demande_reouverture] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_demande_reouverture_decision] CHECK ([etat]='EN_ATTENTE' AND [decide_par] IS NULL AND [decide_le] IS NULL OR [etat]<>'EN_ATTENTE' AND [decide_par] IS NOT NULL AND [decide_le] IS NOT NULL),
    CONSTRAINT [ck_demande_reouverture_ecart] CHECK ([etat]='ECARTEE' AND len(ltrim(rtrim(isnull([motif_ecart],N''))))>(0) OR [etat]<>'ECARTEE' AND [motif_ecart] IS NULL),
    CONSTRAINT [ck_demande_reouverture_etat] CHECK ([etat]='ECARTEE' OR [etat]='ACCORDEE' OR [etat]='EN_ATTENTE'),
    CONSTRAINT [ck_demande_reouverture_motif] CHECK (len(ltrim(rtrim([motif])))>(0)),
    CONSTRAINT [ck_demande_reouverture_nature] CHECK ([nature]='REOUVERTURE'),
    CONSTRAINT [ck_demande_reouverture_roles] CHECK ([decide_par] IS NULL OR [decide_par]<>[demande_par]),
    CONSTRAINT [ck_demande_reouverture_visa] CHECK ([etat]='ACCORDEE' AND [visa_id] IS NOT NULL OR [etat]<>'ACCORDEE' AND [visa_id] IS NULL),
    CONSTRAINT [fk_demande_reouverture_visa] FOREIGN KEY ([visa_id]) REFERENCES [dbo].[visa] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [uq_demande_reouverture_en_attente]
    ON [dbo].[demande_reouverture]([entite] ASC, [arrete] ASC, [nature] ASC) WHERE ([etat]='EN_ATTENTE');


GO

CREATE   TRIGGER dbo.tr_demande_reouverture_figee ON dbo.demande_reouverture
AFTER UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- une suppression pure (aucune ligne inseree) sous semis : remise d'un jeu de recette
    IF NOT EXISTS (SELECT 1 FROM inserted) AND ISNULL(CAST(SESSION_CONTEXT(N'semis') AS INT), 0) = 1
        RETURN;
    IF EXISTS (SELECT 1 FROM deleted d LEFT JOIN inserted i ON i.id = d.id
               WHERE d.etat <> 'EN_ATTENTE' OR i.id IS NULL
                  OR i.entite <> d.entite OR i.arrete <> d.arrete OR i.nature <> d.nature OR i.motif <> d.motif
                  OR i.demande_par <> d.demande_par OR i.demande_le <> d.demande_le)
        THROW 50999, N'Écriture refusée : une demande de réouverture décidée ne change plus, et aucune demande ne se supprime.', 1;
END;

GO

