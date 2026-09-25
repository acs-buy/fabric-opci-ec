CREATE TABLE [dbo].[programme_question] (
    [programme_id] INT            NOT NULL,
    [question_id]  INT            NOT NULL,
    [actif]        BIT            DEFAULT ((1)) NOT NULL,
    [origine]      VARCHAR (5)    NOT NULL,
    [modifie_par]  NVARCHAR (400) NOT NULL,
    [modifie_le]   DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_programme_question] PRIMARY KEY CLUSTERED ([programme_id] ASC, [question_id] ASC),
    CONSTRAINT [ck_pq_origine] CHECK ([origine]='AJOUT' OR [origine]='TYPE'),
    CONSTRAINT [fk_pq_programme] FOREIGN KEY ([programme_id]) REFERENCES [dbo].[programme_travail] ([id]),
    CONSTRAINT [fk_pq_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

