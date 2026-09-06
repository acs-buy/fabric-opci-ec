CREATE TABLE [dbo].[mouvement_porteur] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [porteur_id]   INT             NOT NULL,
    [date_valeur]  VARCHAR (20)    NOT NULL,
    [nature]       VARCHAR (14)    NOT NULL,
    [nombre_parts] DECIMAL (19, 4) DEFAULT ((0)) NOT NULL,
    [montant]      DECIMAL (19, 2) NOT NULL,
    [saisi_par]    NVARCHAR (200)  NOT NULL,
    [saisi_le]     DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_mouvement_porteur] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_mp_montant] CHECK ([montant]>(0)),
    CONSTRAINT [ck_mp_nature] CHECK ([nature]='DISTRIBUTION' OR [nature]='RACHAT' OR [nature]='SOUSCRIPTION'),
    CONSTRAINT [ck_mp_parts] CHECK ([nature]='DISTRIBUTION' AND [nombre_parts]=(0) OR [nature]<>'DISTRIBUTION' AND [nombre_parts]>(0)),
    CONSTRAINT [fk_mp_porteur] FOREIGN KEY ([porteur_id]) REFERENCES [dbo].[porteur] ([id])
);


GO

