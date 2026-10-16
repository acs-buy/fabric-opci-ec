CREATE TABLE [dbo].[annexe_w_nom] (
    [calcul_id] INT             NOT NULL,
    [article]   VARCHAR (10)    NOT NULL,
    [code]      VARCHAR (24)    NOT NULL,
    [nom]       NVARCHAR (1600) NOT NULL,
    CONSTRAINT [pk_annexe_w_nom] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [article] ASC, [code] ASC)
);


GO

