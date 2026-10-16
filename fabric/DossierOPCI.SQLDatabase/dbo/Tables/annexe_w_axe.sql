CREATE TABLE [dbo].[annexe_w_axe] (
    [calcul_id]  INT             NOT NULL,
    [arrete]     VARCHAR (20)    NOT NULL,
    [compte_num] VARCHAR (40)    NOT NULL,
    [code_actif] VARCHAR (40)    NULL,
    [solde]      DECIMAL (19, 2) NOT NULL,
    [n]          INT             NOT NULL,
    [aff]        BIT             NOT NULL
);


GO

