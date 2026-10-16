CREATE TABLE [dbo].[annexe_w_sol] (
    [calcul_id]    INT             NOT NULL,
    [arrete]       VARCHAR (20)    NOT NULL,
    [compte_num]   VARCHAR (40)    NOT NULL,
    [comp_aux_num] NVARCHAR (40)   NULL,
    [aff]          BIT             NOT NULL,
    [solde]        DECIMAL (19, 2) NOT NULL,
    [n]            INT             NOT NULL
);


GO

CREATE CLUSTERED INDEX [ix_annexe_w_sol]
    ON [dbo].[annexe_w_sol]([calcul_id] ASC, [arrete] ASC, [compte_num] ASC);


GO

