CREATE TABLE [dbo].[porteur] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [entite]       VARCHAR (20)   NOT NULL,
    [code]         VARCHAR (20)   NOT NULL,
    [denomination] NVARCHAR (200) NOT NULL,
    [source]       NVARCHAR (200) NOT NULL,
    CONSTRAINT [pk_porteur] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [fk_porteur_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_porteur] UNIQUE NONCLUSTERED ([entite] ASC, [code] ASC)
);


GO

