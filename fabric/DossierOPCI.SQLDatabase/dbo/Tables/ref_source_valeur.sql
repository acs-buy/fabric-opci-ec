CREATE TABLE [dbo].[ref_source_valeur] (
    [source]      VARCHAR (20)   NOT NULL,
    [libelle]     NVARCHAR (60)  NOT NULL,
    [saisissable] BIT            NOT NULL,
    [ordre]       INT            NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_source_valeur] PRIMARY KEY CLUSTERED ([source] ASC),
    CONSTRAINT [uq_ref_source_valeur_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_source_valeur_horodatage]
ON dbo.[ref_source_valeur]
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
    FROM dbo.[ref_source_valeur] t
    JOIN inserted i ON t.[source] = i.[source];
END;

GO

