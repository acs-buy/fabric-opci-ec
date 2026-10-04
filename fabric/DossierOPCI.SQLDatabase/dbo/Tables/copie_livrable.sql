CREATE TABLE [dbo].[copie_livrable] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [document_id] INT            NOT NULL,
    [web_url]     NVARCHAR (800) NOT NULL,
    [copie_par]   NVARCHAR (400) NOT NULL,
    [copie_le]    DATETIME2 (3)  CONSTRAINT [df_copie_le] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_copie_livrable] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_copie_web_url] CHECK ([web_url] like 'https://%'),
    CONSTRAINT [fk_copie_document] FOREIGN KEY ([document_id]) REFERENCES [dbo].[document_produit] ([id])
);


GO

