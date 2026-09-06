CREATE TABLE [dbo].[export_fec_lot] (
    [export_id] INT NOT NULL,
    [lot_id]    INT NOT NULL,
    CONSTRAINT [pk_export_fec_lot] PRIMARY KEY CLUSTERED ([export_id] ASC, [lot_id] ASC),
    CONSTRAINT [fk_export_fec_lot_export] FOREIGN KEY ([export_id]) REFERENCES [dbo].[export_fec] ([id]),
    CONSTRAINT [fk_export_fec_lot_lot] FOREIGN KEY ([lot_id]) REFERENCES [dbo].[lot_ecritures] ([id])
);


GO

