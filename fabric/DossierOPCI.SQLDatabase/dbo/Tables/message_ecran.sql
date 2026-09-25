CREATE TABLE [dbo].[message_ecran] (
    [pour]          NVARCHAR (400)  NOT NULL,
    [entite]        VARCHAR (20)    CONSTRAINT [df_message_ecran_entite] DEFAULT ('-') NOT NULL,
    [genre]         VARCHAR (10)    NOT NULL,
    [message]       NVARCHAR (2000) NOT NULL,
    [geste]         NVARCHAR (400)  NULL,
    [procedure_nom] VARCHAR (128)   NULL,
    [pose_le]       DATETIME2 (0)   CONSTRAINT [df_message_ecran_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_message_ecran] PRIMARY KEY CLUSTERED ([pour] ASC, [entite] ASC),
    CONSTRAINT [ck_message_ecran_genre] CHECK ([genre]='REFUS' OR [genre]='SUCCES')
);


GO

