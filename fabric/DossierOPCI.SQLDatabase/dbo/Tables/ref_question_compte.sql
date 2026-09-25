CREATE TABLE [dbo].[ref_question_compte] (
    [question_id] INT            NOT NULL,
    [racine]      VARCHAR (4)    NOT NULL,
    [source]      NVARCHAR (200) NOT NULL,
    CONSTRAINT [pk_ref_question_compte] PRIMARY KEY CLUSTERED ([question_id] ASC, [racine] ASC),
    CONSTRAINT [fk_rqc_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO

