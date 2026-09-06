CREATE TABLE [dbo].[feuille_question] (
    [cote]                 VARCHAR (30)    NOT NULL,
    [question_id]          INT             NOT NULL,
    [reponse]              VARCHAR (20)    NULL,
    [motif_non_applicable] NVARCHAR (400)  NULL,
    [repondu_par]          NVARCHAR (200)  NULL,
    [repondu_le]           DATETIME2 (3)   NULL,
    [id]                   INT             IDENTITY (1, 1) NOT NULL,
    [commentaire]          NVARCHAR (1000) NULL,
    [reponse_valeur]       NVARCHAR (400)  NULL,
    CONSTRAINT [pk_feuille_question] PRIMARY KEY CLUSTERED ([cote] ASC, [question_id] ASC),
    CONSTRAINT [ck_fq_na_motive] CHECK ([reponse] IS NULL OR [reponse]<>'NON_APPLICABLE' OR [motif_non_applicable] IS NOT NULL),
    CONSTRAINT [ck_fq_reponse] CHECK ([reponse] IS NULL OR ([reponse]='NON_APPLICABLE' OR [reponse]='NON' OR [reponse]='OUI')),
    CONSTRAINT [ck_fq_reponse_visee] CHECK ([reponse] IS NULL AND [reponse_valeur] IS NULL AND [repondu_par] IS NULL AND [repondu_le] IS NULL OR ([reponse] IS NOT NULL OR [reponse_valeur] IS NOT NULL) AND [repondu_par] IS NOT NULL AND [repondu_le] IS NOT NULL),
    CONSTRAINT [fk_fq_feuille] FOREIGN KEY ([cote]) REFERENCES [dbo].[feuille_travail] ([cote]),
    CONSTRAINT [fk_fq_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [uq_feuille_question_id]
    ON [dbo].[feuille_question]([id] ASC);


GO

