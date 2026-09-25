CREATE TABLE [dbo].[export_fec] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [profil]           VARCHAR (10)    NOT NULL,
    [perimetre]        VARCHAR (20)    NOT NULL,
    [arrete]           VARCHAR (20)    NOT NULL,
    [entite]           VARCHAR (20)    NOT NULL,
    [nom_fichier]      NVARCHAR (400)  NOT NULL,
    [empreinte_sha256] CHAR (64)       NOT NULL,
    [lignes]           INT             NOT NULL,
    [total_debit]      DECIMAL (19, 2) NOT NULL,
    [total_credit]     DECIMAL (19, 2) NOT NULL,
    [produit_par]      NVARCHAR (200)  NOT NULL,
    [produit_le]       DATETIME2 (7)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_export_fec] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_export_empreinte_longueur] CHECK (len([empreinte_sha256])=(64)),
    CONSTRAINT [ck_export_equilibre] CHECK ([total_debit]=[total_credit]),
    CONSTRAINT [ck_export_lignes] CHECK ([lignes]>=(1)),
    CONSTRAINT [ck_export_pas_de_fiscal_complementaire] CHECK ([profil]<>'FISCAL' OR [perimetre]<>'COMPLEMENTAIRE'),
    CONSTRAINT [ck_export_perimetre] CHECK ([perimetre]='COMPLEMENTAIRE' OR [perimetre]='COMPLET'),
    CONSTRAINT [ck_export_profil] CHECK ([profil]='INTEROP' OR [profil]='FISCAL'),
    CONSTRAINT [fk_export_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_export_fec_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_export_empreinte] UNIQUE NONCLUSTERED ([empreinte_sha256] ASC)
);


GO

