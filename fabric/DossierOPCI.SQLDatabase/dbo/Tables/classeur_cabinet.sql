CREATE TABLE [dbo].[classeur_cabinet] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [genre]            VARCHAR (12)   NOT NULL,
    [referentiel]      VARCHAR (120)  NULL,
    [fichier]          NVARCHAR (400) NOT NULL,
    [web_url]          NVARCHAR (800) NULL,
    [chemin_onelake]   NVARCHAR (800) NULL,
    [empreinte_sha256] CHAR (64)      NOT NULL,
    [depose_par]       NVARCHAR (400) NOT NULL,
    [depose_le]        DATETIME2 (0)  CONSTRAINT [df_classeur_cabinet_depose_le] DEFAULT (CONVERT([datetime2](0),CONVERT([varchar](19),sysutcdatetime(),(120)))) NOT NULL,
    CONSTRAINT [pk_classeur_cabinet] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_classeur_cabinet_genre] CHECK ([genre]='NIVEAUX' OR [genre]='REFERENTIEL'),
    CONSTRAINT [ck_classeur_cabinet_referentiel] CHECK ([genre]='REFERENTIEL' AND [referentiel] IS NOT NULL OR [genre]='NIVEAUX' AND [referentiel] IS NULL)
);


GO

CREATE NONCLUSTERED INDEX [ix_classeur_cabinet_dernier]
    ON [dbo].[classeur_cabinet]([genre] ASC, [referentiel] ASC, [depose_le] DESC, [id] DESC)
    INCLUDE([fichier], [web_url], [chemin_onelake]);


GO

