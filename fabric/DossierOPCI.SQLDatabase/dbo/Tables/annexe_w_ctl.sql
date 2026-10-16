CREATE TABLE [dbo].[annexe_w_ctl] (
    [calcul_id] INT              NOT NULL,
    [arrete]    VARCHAR (20)     NOT NULL,
    [controle]  VARCHAR (24)     NOT NULL,
    [cle]       NVARCHAR (120)   NOT NULL,
    [ecart]     DECIMAL (38, 12) NOT NULL,
    CONSTRAINT [pk_annexe_w_ctl] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [arrete] ASC, [controle] ASC, [cle] ASC)
);


GO

