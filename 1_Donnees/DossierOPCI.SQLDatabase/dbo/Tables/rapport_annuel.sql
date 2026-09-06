CREATE TABLE [dbo].[rapport_annuel] (
    [id]                       INT             IDENTITY (1, 1) NOT NULL,
    [entite]                   VARCHAR (20)    NOT NULL,
    [arrete]                   VARCHAR (20)    NOT NULL,
    [exercice]                 VARCHAR (20)    NOT NULL,
    [arrete_au]                VARCHAR (30)    NOT NULL,
    [rapport_gestion]          SMALLINT        DEFAULT ((0)) NOT NULL,
    [documents_synthese]       SMALLINT        DEFAULT ((0)) NOT NULL,
    [certification_cac]        SMALLINT        DEFAULT ((0)) NOT NULL,
    [rapport_conseil_fpi]      SMALLINT        NULL,
    [changements_substantiels] NVARCHAR (1000) NULL,
    [prepare_par]              NVARCHAR (200)  NOT NULL,
    [prepare_le]               DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [piece_synthese_id]        INT             NULL,
    [piece_certification_id]   INT             NULL,
    CONSTRAINT [pk_rapport_annuel] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ra_arrete_au] CHECK ([arrete_au]='DERNIERE_VL_PUBLIEE' OR [arrete_au]='DERNIER_JOUR_EXERCICE'),
    CONSTRAINT [ck_ra_pieces] CHECK (([rapport_gestion]=(1) OR [rapport_gestion]=(0)) AND ([documents_synthese]=(1) OR [documents_synthese]=(0)) AND ([certification_cac]=(1) OR [certification_cac]=(0)) AND ([rapport_conseil_fpi] IS NULL OR ([rapport_conseil_fpi]=(1) OR [rapport_conseil_fpi]=(0)))),
    CONSTRAINT [fk_ra_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ra_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rapport_piece_certification] FOREIGN KEY ([piece_certification_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_rapport_piece_synthese] FOREIGN KEY ([piece_synthese_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [uq_rapport_annuel] UNIQUE NONCLUSTERED ([entite] ASC, [exercice] ASC)
);


GO

