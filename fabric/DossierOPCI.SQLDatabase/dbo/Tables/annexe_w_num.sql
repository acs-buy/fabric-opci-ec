CREATE TABLE [dbo].[annexe_w_num] (
    [calcul_id] INT              NOT NULL,
    [cle]       VARCHAR (20)     NOT NULL,
    [arrete]    VARCHAR (20)     NOT NULL,
    [valeur]    DECIMAL (38, 12) NULL,
    CONSTRAINT [pk_annexe_w_num] PRIMARY KEY CLUSTERED ([calcul_id] ASC, [cle] ASC, [arrete] ASC)
);


GO

