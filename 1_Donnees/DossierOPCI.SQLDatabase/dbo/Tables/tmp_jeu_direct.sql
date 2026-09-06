CREATE TABLE [dbo].[tmp_jeu_direct] (
    [rang]           SMALLINT        NOT NULL,
    [code_immeuble]  VARCHAR (20)    NOT NULL,
    [prix_revient]   DECIMAL (19, 2) NOT NULL,
    [loyers_2024]    DECIMAL (19, 2) NOT NULL,
    [loyers_2025]    DECIMAL (19, 2) NOT NULL,
    [charges_2024]   DECIMAL (19, 2) NOT NULL,
    [charges_2025]   DECIMAL (19, 2) NOT NULL,
    [juste_val_2024] DECIMAL (19, 2) NOT NULL,
    [juste_val_2025] DECIMAL (19, 2) NOT NULL,
    [travaux_2025]   DECIMAL (19, 2) NOT NULL,
    CONSTRAINT [pk_tmp_jeu_direct] PRIMARY KEY CLUSTERED ([code_immeuble] ASC)
);


GO

