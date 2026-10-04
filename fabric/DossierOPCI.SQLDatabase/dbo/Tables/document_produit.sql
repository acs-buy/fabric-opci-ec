CREATE TABLE [dbo].[document_produit] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [entite]               VARCHAR (20)   NOT NULL,
    [arrete]               VARCHAR (20)   NOT NULL,
    [livrable]             VARCHAR (20)   NOT NULL,
    [version]              INT            NOT NULL,
    [chemin_coffre]        NVARCHAR (600) NULL,
    [empreinte_sha256]     CHAR (64)      NOT NULL,
    [produit_par]          NVARCHAR (400) NOT NULL,
    [produit_le]           DATETIME2 (3)  NOT NULL,
    [perime_le]            DATETIME2 (3)  NULL,
    [perime_motif]         NVARCHAR (600) NULL,
    [format]               VARCHAR (4)    NULL,
    [fichier]              NVARCHAR (400) NULL,
    [web_url]              NVARCHAR (800) NULL,
    [empreinte_stockee]    CHAR (64)      NULL,
    [empreinte_stockee_le] DATETIME2 (3)  NULL,
    [couvre_version]       INT            NULL,
    CONSTRAINT [pk_document_produit] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_document_empreinte] CHECK (len([empreinte_sha256])=(64)),
    CONSTRAINT [ck_document_empreinte_stockee] CHECK ([empreinte_stockee] IS NULL AND [empreinte_stockee_le] IS NULL OR len([empreinte_stockee])=(64) AND [empreinte_stockee_le] IS NOT NULL),
    CONSTRAINT [ck_document_format] CHECK ([format]='PDF' OR [format]='XLSX' OR [format]='DOCX'),
    CONSTRAINT [ck_document_perime] CHECK ([perime_le] IS NULL AND [perime_motif] IS NULL OR [perime_le] IS NOT NULL AND [perime_motif] IS NOT NULL),
    CONSTRAINT [fk_document_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_document_livrable] FOREIGN KEY ([livrable]) REFERENCES [dbo].[ref_livrable] ([code]),
    CONSTRAINT [uq_document_produit] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [livrable] ASC, [version] ASC, [format] ASC)
);


GO

