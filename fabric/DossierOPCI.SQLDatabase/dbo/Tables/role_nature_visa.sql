CREATE TABLE [dbo].[role_nature_visa] (
    [role_code]   VARCHAR (20)   NOT NULL,
    [nature]      VARCHAR (12)   NOT NULL,
    [motif]       NVARCHAR (300) NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_role_nature_visa] PRIMARY KEY CLUSTERED ([role_code] ASC, [nature] ASC),
    CONSTRAINT [ck_rnv_nature] CHECK ([nature]='REVUE' OR [nature]='CYCLE' OR [nature]='LOT' OR [nature]='CONCLUSION' OR [nature]='DEROGATION' OR [nature]='EVALUATION' OR [nature]='PUBLICATION' OR [nature]='OBLIGATION' OR [nature]='ACCEPTATION' OR [nature]='MAINTIEN' OR [nature]='SYNTHESE' OR [nature]='CLOTURE'),
    CONSTRAINT [fk_rnv_role] FOREIGN KEY ([role_code]) REFERENCES [dbo].[ref_role] ([code])
);


GO

CREATE   TRIGGER dbo.[tr_role_nature_visa_garde]
ON dbo.[role_nature_visa]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('role_nature_visa',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_role_nature_visa_horodatage]
ON dbo.[role_nature_visa]
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
    FROM dbo.[role_nature_visa] t
    JOIN inserted i ON t.[role_code] = i.[role_code] AND t.[nature] = i.[nature];
END;

GO

