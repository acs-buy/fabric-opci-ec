CREATE TABLE [dbo].[publication_client] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [entite]      VARCHAR (20)   NOT NULL,
    [arrete]      VARCHAR (20)   NOT NULL,
    [visa_id]     INT            NOT NULL,
    [etat]        VARCHAR (10)   NOT NULL,
    [publiee_le]  DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [publiee_par] NVARCHAR (200) NOT NULL,
    [motif]       NVARCHAR (600) NULL,
    [terminee_le] DATETIME2 (3)  NULL,
    CONSTRAINT [pk_publication_client] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_publication_client_etat] CHECK ([etat]='EN_ECHEC' OR [etat]='PUBLIEE' OR [etat]='EN_COURS'),
    CONSTRAINT [fk_publication_client_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_publication_client_visa] FOREIGN KEY ([visa_id]) REFERENCES [dbo].[visa] ([id])
);


GO

