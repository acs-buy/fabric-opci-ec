CREATE TABLE [dbo].[annexe_version] (
    [entite]                      VARCHAR (20)   NOT NULL,
    [arrete]                      VARCHAR (20)   NOT NULL,
    [version]                     INT            NOT NULL,
    [arrete_cree_le]              DATETIME2 (7)  CONSTRAINT [df_annexe_version_arrete_cree_le] DEFAULT ('1900-01-01') NOT NULL,
    [calcul_id]                   INT            NOT NULL,
    [cree_le]                     DATETIME2 (3)  NOT NULL,
    [cree_par]                    NVARCHAR (400) NOT NULL,
    [declencheur]                 VARCHAR (12)   NOT NULL,
    [cellules]                    INT            NOT NULL,
    [a_remplir]                   INT            NOT NULL,
    [en_attente]                  INT            NOT NULL,
    [cellules_changees]           INT            NULL,
    [cellules_imprimees_changees] INT            NULL,
    CONSTRAINT [pk_annexe_version] PRIMARY KEY CLUSTERED ([entite] ASC, [arrete] ASC, [version] ASC)
);


GO

