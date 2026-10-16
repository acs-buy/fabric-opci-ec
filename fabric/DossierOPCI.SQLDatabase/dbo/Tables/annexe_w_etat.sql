CREATE TABLE [dbo].[annexe_w_etat] (
    [calcul_id]   INT              NOT NULL,
    [arrete]      VARCHAR (20)     NOT NULL,
    [code]        VARCHAR (40)     NOT NULL,
    [exercice_n]  DECIMAL (38, 12) NULL,
    [exercice_n1] DECIMAL (38, 12) NULL,
    CONSTRAINT [pk_annexe_w_etat] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [arrete] ASC, [code] ASC)
);


GO

