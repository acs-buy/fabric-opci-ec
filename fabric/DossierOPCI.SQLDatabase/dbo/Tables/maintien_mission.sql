CREATE TABLE [dbo].[maintien_mission] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [arrete_conclu]      VARCHAR (20)    NOT NULL,
    [statut]             VARCHAR (10)    DEFAULT ('OUVERT') NOT NULL,
    [decision]           VARCHAR (10)    NULL,
    [motif]              NVARCHAR (400)  NULL,
    [approuve_par]       NVARCHAR (200)  NULL,
    [approuve_le]        DATETIME2 (3)   NULL,
    [cree_par]           NVARCHAR (200)  NOT NULL,
    [cree_le]            DATETIME2 (7)   DEFAULT (sysutcdatetime()) NOT NULL,
    [cote_questionnaire] VARCHAR (30)    NULL,
    [reprise_motif]      NVARCHAR (800)  NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    CONSTRAINT [pk_maintien_mission] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_maintien_decision] CHECK ([decision] IS NULL OR ([decision]='EN_ATTENTE' OR [decision]='ROMPU' OR [decision]='MAINTENU')),
    CONSTRAINT [ck_maintien_statut] CHECK ([statut]='REFUSE' OR [statut]='APPROUVE' OR [statut]='OUVERT'),
    CONSTRAINT [ck_maintien_visa] CHECK ([statut]<>'APPROUVE' OR [approuve_par] IS NOT NULL AND [approuve_le] IS NOT NULL),
    CONSTRAINT [fk_maintien_arrete] FOREIGN KEY ([entite], [arrete_conclu]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_maintien_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_maintien] UNIQUE NONCLUSTERED ([entite] ASC, [arrete_conclu] ASC)
);


GO

