CREATE TABLE [dbo].[ref_cycle_compte] (
    [cycle]  VARCHAR (10)   NOT NULL,
    [racine] VARCHAR (4)    NOT NULL,
    [source] NVARCHAR (200) NOT NULL,
    CONSTRAINT [pk_ref_cycle_compte] PRIMARY KEY CLUSTERED ([cycle] ASC, [racine] ASC),
    CONSTRAINT [fk_rcc_cycle] FOREIGN KEY ([cycle]) REFERENCES [dbo].[ref_cycle] ([code])
);


GO

