CREATE TABLE [dbo].[annexe_w_cel] (
    [calcul_id]      INT              NOT NULL,
    [arrete]         VARCHAR (20)     NOT NULL,
    [article]        VARCHAR (10)     NOT NULL,
    [ligne]          NVARCHAR (120)   NOT NULL,
    [colonne]        TINYINT          NOT NULL,
    [etat]           VARCHAR (12)     NOT NULL,
    [valeur]         DECIMAL (38, 12) NULL,
    [texte_valeur]   NVARCHAR (2000)  NULL,
    [fmt]            VARCHAR (10)     NOT NULL,
    [source]         NVARCHAR (MAX)   NULL,
    [formule]        NVARCHAR (MAX)   NULL,
    [regle]          VARCHAR (12)     NULL,
    [obligation]     VARCHAR (14)     NULL,
    [nature]         VARCHAR (8)      NOT NULL,
    [motif]          NVARCHAR (MAX)   NULL,
    [vb_num]         DECIMAL (38, 12) NULL,
    [vb_txt]         NVARCHAR (2000)  NULL,
    [saisie_ecartee] NVARCHAR (400)   NULL,
    [libelle]        NVARCHAR (500)   NULL,
    [ordre_declare]  DECIMAL (19, 6)  NULL,
    [signe]          VARCHAR (4)      NULL,
    [groupe]         VARCHAR (40)     NULL,
    [rang]           INT              NOT NULL,
    [texte]          NVARCHAR (2000)  NULL,
    [texte_imprime]  NVARCHAR (2000)  NULL,
    [ordre]          SMALLINT         NULL,
    [attend]         NVARCHAR (MAX)   NULL,
    [attend_exigee]  BIT              NULL,
    CONSTRAINT [pk_annexe_w_cel] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [arrete] ASC, [article] ASC, [ligne] ASC, [colonne] ASC)
);


GO

