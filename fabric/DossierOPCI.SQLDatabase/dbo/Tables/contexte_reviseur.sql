CREATE TABLE [dbo].[contexte_reviseur] (
    [utilisateur] NVARCHAR (200) CONSTRAINT [df_contexte_utilisateur] DEFAULT (user_name()) NOT NULL,
    [vehicule]    VARCHAR (20)   NULL,
    [arrete]      DATE           NULL,
    [modifie_le]  DATETIME2 (0)  CONSTRAINT [df_contexte_modifie] DEFAULT (sysdatetime()) NOT NULL,
    CONSTRAINT [pk_contexte_reviseur] PRIMARY KEY CLUSTERED ([utilisateur] ASC),
    CONSTRAINT [fk_contexte_vehicule] FOREIGN KEY ([vehicule]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

