CREATE TABLE [dbo].[eligibilite_participation] (
    [entite_mere]             VARCHAR (20)   NOT NULL,
    [entite_fille]            VARCHAR (20)   NOT NULL,
    [comptes_semestriels]     INT            NULL,
    [immeubles_conformes]     INT            NULL,
    [cas_relation]            CHAR (1)       NULL,
    [droits_de_vote]          DECIMAL (9, 6) NULL,
    [autre_associe_superieur] INT            NULL,
    [accord_ecrit_piece_id]   INT            NULL,
    [qualifie_par]            NVARCHAR (400) NULL,
    [qualifie_le]             DATETIME2 (3)  NULL,
    [note]                    NVARCHAR (800) NULL,
    CONSTRAINT [pk_eligibilite_participation] PRIMARY KEY CLUSTERED ([entite_mere] ASC, [entite_fille] ASC),
    CONSTRAINT [ck_elig_accord_ecrit] CHECK ([cas_relation]<>'e' OR [accord_ecrit_piece_id] IS NOT NULL),
    CONSTRAINT [ck_elig_bits] CHECK (([comptes_semestriels] IS NULL OR ([comptes_semestriels]=(1) OR [comptes_semestriels]=(0))) AND ([immeubles_conformes] IS NULL OR ([immeubles_conformes]=(1) OR [immeubles_conformes]=(0))) AND ([autre_associe_superieur] IS NULL OR ([autre_associe_superieur]=(1) OR [autre_associe_superieur]=(0)))),
    CONSTRAINT [fk_elig_accord] FOREIGN KEY ([accord_ecrit_piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_elig_cas] FOREIGN KEY ([cas_relation]) REFERENCES [dbo].[ref_cas_eligibilite] ([cas]),
    CONSTRAINT [fk_elig_fille] FOREIGN KEY ([entite_fille]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_elig_mere] FOREIGN KEY ([entite_mere]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

