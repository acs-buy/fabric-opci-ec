CREATE TABLE [dbo].[annexe_w_ops] (
    [calcul_id]  INT            NOT NULL,
    [arrete]     VARCHAR (20)   NOT NULL,
    [article]    VARCHAR (10)   NOT NULL,
    [ligne]      NVARCHAR (120) NOT NULL,
    [colonne]    TINYINT        NOT NULL,
    [n]          INT            NOT NULL,
    [op_article] VARCHAR (10)   NOT NULL,
    [op_ligne]   NVARCHAR (120) NOT NULL,
    [op_colonne] TINYINT        NOT NULL,
    CONSTRAINT [pk_annexe_w_ops] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [arrete] ASC, [article] ASC, [ligne] ASC, [colonne] ASC, [n] ASC)
);


GO

