CREATE TABLE [dbo].[calcul_annexe] (
    [calcul_id]         INT            IDENTITY (1, 1) NOT NULL,
    [entite]            VARCHAR (20)   NOT NULL,
    [arrete]            VARCHAR (20)   NULL,
    [declencheur]       VARCHAR (12)   NOT NULL,
    [demande_par]       NVARCHAR (400) NOT NULL,
    [debut]             DATETIME2 (3)  NOT NULL,
    [fin]               DATETIME2 (3)  NULL,
    [arretes]           NVARCHAR (MAX) NULL,
    [versions_creees]   NVARCHAR (MAX) NULL,
    [cellules]          INT            NULL,
    [cellules_changees] INT            NULL,
    [a_remplir]         INT            NULL,
    [en_attente]        INT            NULL,
    [documents_perimes] INT            NULL,
    [premier]           BIT            NULL,
    CONSTRAINT [pk_calcul_annexe] PRIMARY KEY CLUSTERED ([calcul_id] ASC),
    CONSTRAINT [ck_calcul_annexe_declencheur] CHECK ([declencheur]='VALIDATION' OR [declencheur]='SOURCE' OR [declencheur]='BOUTON' OR [declencheur]='PRODUCTION' OR [declencheur]='VISA_REVUE' OR [declencheur]='SAISIE')
);


GO

CREATE NONCLUSTERED INDEX [ix_calcul_annexe_entite]
    ON [dbo].[calcul_annexe]([entite] ASC, [calcul_id] ASC);


GO

