CREATE TABLE [31e46168-a84d-491d-9615-f018f7009712].[blend_sheet_source_mapping] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [blendSheetId] NVARCHAR (128) NOT NULL,
    [sourceId]     VARCHAR (255)  NOT NULL,
    [sourceType]   INT            NOT NULL,
    [createdAt]    INT            NOT NULL,
    [updatedAt]    INT            NOT NULL,
    [createdBy]    NVARCHAR (128) NOT NULL,
    [updatedBy]    NVARCHAR (128) NOT NULL,
    CONSTRAINT [PK_blend_sheet_source_mapping] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [FK_blend_sheet_source_mapping_blendSheetId] FOREIGN KEY ([blendSheetId]) REFERENCES [31e46168-a84d-491d-9615-f018f7009712].[blend_sheets] ([id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [idx_blend_sheet_source_mapping_blendSheetId]
    ON [31e46168-a84d-491d-9615-f018f7009712].[blend_sheet_source_mapping]([blendSheetId] ASC);


GO

CREATE NONCLUSTERED INDEX [idx_blend_sheet_source_mapping_sourceId]
    ON [31e46168-a84d-491d-9615-f018f7009712].[blend_sheet_source_mapping]([sourceId] ASC);


GO

