CREATE TABLE [dbo].[tmp_jeu_filiale] (
    [rang]           SMALLINT        NOT NULL,
    [entite]         VARCHAR (20)    NOT NULL,
    [code_immeuble]  VARCHAR (20)    NOT NULL,
    [quote_part]     DECIMAL (9, 6)  NOT NULL,
    [prix_revient]   DECIMAL (19, 2) NOT NULL,
    [capital]        DECIMAL (19, 2) NOT NULL,
    [emprunt]        DECIMAL (19, 2) NOT NULL,
    [loyers_2024]    DECIMAL (19, 2) NOT NULL,
    [loyers_2025]    DECIMAL (19, 2) NOT NULL,
    [charges_2024]   DECIMAL (19, 2) NOT NULL,
    [charges_2025]   DECIMAL (19, 2) NOT NULL,
    [interets_2024]  DECIMAL (19, 2) NOT NULL,
    [interets_2025]  DECIMAL (19, 2) NOT NULL,
    [juste_val_2024] DECIMAL (19, 2) NOT NULL,
    [juste_val_2025] DECIMAL (19, 2) NOT NULL,
    [travaux_2025]   DECIMAL (19, 2) NOT NULL,
    CONSTRAINT [pk_tmp_jeu_filiale] PRIMARY KEY CLUSTERED ([entite] ASC)
);


GO

