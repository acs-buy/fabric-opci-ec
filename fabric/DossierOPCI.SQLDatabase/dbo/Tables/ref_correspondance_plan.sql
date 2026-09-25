CREATE TABLE [dbo].[ref_correspondance_plan] (
    [norme_source]  VARCHAR (14)   NOT NULL,
    [compte_source] VARCHAR (20)   NOT NULL,
    [compte_modele] VARCHAR (20)   NOT NULL,
    [motif]         NVARCHAR (600) NOT NULL,
    [reference_id]  INT            NULL,
    [modifie_par]   NVARCHAR (400) NULL,
    [modifie_le]    DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_correspondance_plan] PRIMARY KEY CLUSTERED ([norme_source] ASC, [compte_source] ASC),
    CONSTRAINT [fk_rcp_modele] FOREIGN KEY ([compte_modele]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_rcp_norme] FOREIGN KEY ([norme_source]) REFERENCES [dbo].[ref_norme] ([code]),
    CONSTRAINT [fk_rcp_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id])
);


GO

CREATE   TRIGGER dbo.[tr_ref_correspondance_plan_garde]
ON dbo.[ref_correspondance_plan]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_correspondance_plan',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_correspondance_plan_horodatage]
ON dbo.[ref_correspondance_plan]
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
    FROM dbo.[ref_correspondance_plan] t
    JOIN inserted i ON t.[norme_source] = i.[norme_source] AND t.[compte_source] = i.[compte_source];
END;

GO

