CREATE TABLE [dbo].[ref_ratio_vehicule] (
    [entite]      VARCHAR (20)   NOT NULL,
    [code]        VARCHAR (30)   NOT NULL,
    [seuil]       DECIMAL (9, 6) NOT NULL,
    [source]      VARCHAR (12)   NOT NULL,
    [piece_id]    INT            NULL,
    [lu_le]       DATE           NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_ratio_vehicule] PRIMARY KEY CLUSTERED ([entite] ASC, [code] ASC),
    CONSTRAINT [ck_rrv_source] CHECK ([source]='GESTIONNAIRE' OR [source]='STATUTS'),
    CONSTRAINT [fk_rrv_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rrv_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_rrv_ratio_memoire] FOREIGN KEY ([code]) REFERENCES [dbo].[ref_ratio_memoire] ([code])
);


GO

CREATE   TRIGGER dbo.[tr_ref_ratio_vehicule_horodatage]
ON dbo.[ref_ratio_vehicule]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Un semis ne marque pas la ligne comme modifiee : sans quoi son
    -- premier passage interdirait a tous les suivants de corriger leurs
    -- propres lignes.
    IF CAST(ISNULL(SESSION_CONTEXT(N'semis'), 0) AS INT) = 1 RETURN;
    IF NOT EXISTS (SELECT 1 FROM inserted) RETURN;
    UPDATE t SET modifie_par = SUSER_SNAME(), modifie_le = SYSUTCDATETIME()
    FROM dbo.[ref_ratio_vehicule] t
    JOIN inserted i ON t.[entite] = i.[entite] AND t.[code] = i.[code];
END;

GO

