CREATE TABLE [dbo].[stg_fec] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [reference_import] VARCHAR (100)   NOT NULL,
    [import_id]        INT             NULL,
    [numero_ligne]     INT             NOT NULL,
    [entite]           VARCHAR (20)    NOT NULL,
    [journal_code]     VARCHAR (10)    NULL,
    [journal_lib]      NVARCHAR (100)  NULL,
    [ecriture_num]     VARCHAR (30)    NULL,
    [ecriture_date]    DATE            NULL,
    [compte_num]       VARCHAR (20)    NULL,
    [compte_lib]       NVARCHAR (200)  NULL,
    [comp_aux_num]     VARCHAR (20)    NULL,
    [comp_aux_lib]     NVARCHAR (200)  NULL,
    [piece_ref]        VARCHAR (50)    NULL,
    [piece_date]       DATE            NULL,
    [ecriture_lib]     NVARCHAR (400)  NULL,
    [debit]            DECIMAL (19, 2) NULL,
    [credit]           DECIMAL (19, 2) NULL,
    [ecriture_let]     VARCHAR (40)    NULL,
    [date_let]         DATE            NULL,
    [valid_date]       DATE            NULL,
    [montant_devise]   DECIMAL (19, 3) NULL,
    [id_devise]        VARCHAR (3)     NULL,
    [recevable]        INT             DEFAULT ((0)) NOT NULL,
    [motif_rejet]      NVARCHAR (400)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_stg_recevable] CHECK ([recevable]=(1) OR [recevable]=(0)),
    CONSTRAINT [fk_stg_fec_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_stg_fec_ligne] UNIQUE NONCLUSTERED ([reference_import] ASC, [numero_ligne] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_stg_fec_import]
    ON [dbo].[stg_fec]([import_id] ASC, [recevable] ASC);


GO

CREATE NONCLUSTERED INDEX [ix_stg_fec_reference]
    ON [dbo].[stg_fec]([reference_import] ASC);


GO

