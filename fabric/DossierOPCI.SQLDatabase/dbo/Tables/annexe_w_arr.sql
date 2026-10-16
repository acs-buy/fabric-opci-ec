CREATE TABLE [dbo].[annexe_w_arr] (
    [calcul_id]        INT          NOT NULL,
    [arrete]           VARCHAR (20) NOT NULL,
    [exercice]         VARCHAR (20) NULL,
    [type_arrete]      VARCHAR (14) NULL,
    [date_arrete]      DATE         NOT NULL,
    [annee]            INT          NOT NULL,
    [porte_balance]    BIT          NOT NULL,
    [arrete_n_1]       VARCHAR (20) NULL,
    [premier_exercice] BIT          NOT NULL,
    [mission]          BIT          NOT NULL,
    CONSTRAINT [pk_annexe_w_arr] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [arrete] ASC)
);


GO

