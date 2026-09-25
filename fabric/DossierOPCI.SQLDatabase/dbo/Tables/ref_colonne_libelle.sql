CREATE TABLE [dbo].[ref_colonne_libelle] (
    [vue]           VARCHAR (128)  NOT NULL,
    [colonne]       VARCHAR (128)  NOT NULL,
    [libelle]       NVARCHAR (120) NOT NULL,
    [libelle_court] NVARCHAR (40)  NOT NULL,
    [aligne]        VARCHAR (7)    NOT NULL,
    [format]        VARCHAR (20)   NULL,
    [ordre]         INT            NOT NULL,
    [visible]       BIT            NOT NULL,
    [tri_rang]      INT            NULL,
    [tri_sens]      VARCHAR (4)    NULL,
    [modifie_par]   NVARCHAR (200) NULL,
    [modifie_le]    DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_colonne_libelle] PRIMARY KEY CLUSTERED ([vue] ASC, [colonne] ASC),
    CONSTRAINT [ck_rcl_aligne] CHECK ([aligne]='CENTRE' OR [aligne]='DROITE' OR [aligne]='GAUCHE'),
    CONSTRAINT [ck_rcl_tri] CHECK ([tri_rang] IS NULL AND [tri_sens] IS NULL OR [tri_rang]>(0) AND ([tri_sens]='DESC' OR [tri_sens]='ASC'))
);


GO

CREATE   TRIGGER dbo.[tr_ref_colonne_libelle_horodatage]
ON dbo.[ref_colonne_libelle]
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
    FROM dbo.[ref_colonne_libelle] t
    JOIN inserted i ON t.[vue] = i.[vue] AND t.[colonne] = i.[colonne];
END;

GO

