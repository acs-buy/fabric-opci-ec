CREATE TABLE [dbo].[demande_espace_client] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [demande_par]        NVARCHAR (400)  NOT NULL,
    [demande_le]         DATETIME2 (3)   CONSTRAINT [df_demande_espace_le] DEFAULT (sysutcdatetime()) NOT NULL,
    [equipe_teams]       BIT             CONSTRAINT [df_demande_espace_equipe] DEFAULT ((1)) NOT NULL,
    [statut]             VARCHAR (12)    CONSTRAINT [df_demande_espace_statut] DEFAULT ('A_FAIRE') NOT NULL,
    [groupe_id]          VARCHAR (40)    NULL,
    [site_url]           NVARCHAR (400)  NULL,
    [reponse]            NVARCHAR (MAX)  NULL,
    [repondu_le]         DATETIME2 (3)   NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    CONSTRAINT [pk_demande_espace_client] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_demande_espace_statut] CHECK ([statut]='ERREUR' OR [statut]='PARTIEL' OR [statut]='FAIT' OR [statut]='A_FAIRE'),
    CONSTRAINT [fk_demande_espace_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

