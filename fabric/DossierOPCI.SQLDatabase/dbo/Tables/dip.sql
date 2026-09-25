CREATE TABLE [dbo].[dip] (
    [id]                    INT            IDENTITY (1, 1) NOT NULL,
    [entite]                VARCHAR (20)   NOT NULL,
    [arrete]                VARCHAR (20)   NOT NULL,
    [exercice]              VARCHAR (20)   NOT NULL,
    [etabli_au]             VARCHAR (30)   NOT NULL,
    [prepare_par]           NVARCHAR (200) NOT NULL,
    [prepare_le]            DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [publie_site]           SMALLINT       DEFAULT ((0)) NOT NULL,
    [motif_non_publication] NVARCHAR (400) NULL,
    [date_arrete]           DATE           NULL,
    [publie_le]             DATE           NULL,
    [envoye_amf_le]         DATE           NULL,
    CONSTRAINT [pk_dip] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_dip_delai_amf] CHECK ([envoye_amf_le] IS NULL OR [date_arrete] IS NULL OR [envoye_amf_le]<=dateadd(week,(9),[date_arrete])),
    CONSTRAINT [ck_dip_delai_publication] CHECK ([publie_le] IS NULL OR [date_arrete] IS NULL OR [publie_le]<=dateadd(week,(8),[date_arrete])),
    CONSTRAINT [ck_dip_etabli_au] CHECK ([etabli_au]='DERNIERE_VL' OR [etabli_au]='DERNIER_JOUR_SEMESTRE'),
    CONSTRAINT [ck_dip_publication] CHECK ([publie_site]=(1) AND [motif_non_publication] IS NULL OR [publie_site]=(0) AND [motif_non_publication] IS NOT NULL),
    CONSTRAINT [fk_dip_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_dip_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [uq_dip] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC)
);


GO

