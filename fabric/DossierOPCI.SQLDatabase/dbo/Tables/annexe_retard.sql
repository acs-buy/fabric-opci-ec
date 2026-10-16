CREATE TABLE [dbo].[annexe_retard] (
    [id]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [entite]   VARCHAR (20)   NOT NULL,
    [ecrit_le] DATETIME2 (3)  NOT NULL,
    [origine]  NVARCHAR (128) NOT NULL,
    [lignes]   INT            NOT NULL,
    CONSTRAINT [pk_annexe_retard] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_annexe_retard_entite]
    ON [dbo].[annexe_retard]([entite] ASC, [id] ASC);


GO

