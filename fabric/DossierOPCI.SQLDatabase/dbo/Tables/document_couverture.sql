CREATE TABLE [dbo].[document_couverture] (
    [document_id]         INT       NOT NULL,
    [document_couvert_id] INT       NOT NULL,
    [empreinte_couverte]  CHAR (64) NOT NULL,
    CONSTRAINT [pk_document_couverture] PRIMARY KEY CLUSTERED ([document_id] ASC, [document_couvert_id] ASC),
    CONSTRAINT [fk_couverture_couvert] FOREIGN KEY ([document_couvert_id]) REFERENCES [dbo].[document_produit] ([id]),
    CONSTRAINT [fk_couverture_document] FOREIGN KEY ([document_id]) REFERENCES [dbo].[document_produit] ([id])
);


GO

