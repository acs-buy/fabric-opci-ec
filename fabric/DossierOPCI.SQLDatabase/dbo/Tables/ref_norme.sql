CREATE TABLE [dbo].[ref_norme] (
    [code]                    VARCHAR (14)   NOT NULL,
    [libelle_court]           NVARCHAR (80)  NOT NULL,
    [libelle_complet]         NVARCHAR (400) NOT NULL,
    [autorite]                VARCHAR (14)   NOT NULL,
    [acte_agrement]           NVARCHAR (200) NULL,
    [date_application]        NVARCHAR (120) NULL,
    [edition]                 NVARCHAR (40)  NULL,
    [piece_au_dossier]        NVARCHAR (200) NULL,
    [en_vigueur]              INT            DEFAULT ((1)) NOT NULL,
    [abroge_par]              VARCHAR (14)   NULL,
    [applicable_presentation] INT            DEFAULT ((0)) NOT NULL,
    [note]                    NVARCHAR (400) NULL,
    [modifie_par]             NVARCHAR (400) NULL,
    [modifie_le]              DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_norme] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_norme_abrogation] CHECK ([en_vigueur]=(1) OR [abroge_par] IS NOT NULL),
    CONSTRAINT [ck_norme_abrogee_inapplicable] CHECK ([en_vigueur]=(1) OR [applicable_presentation]=(0)),
    CONSTRAINT [ck_norme_autorite] CHECK ([autorite]='AMF' OR [autorite]='LEGISLATEUR' OR [autorite]='ANC' OR [autorite]='CNOEC'),
    CONSTRAINT [ck_norme_bit] CHECK (([en_vigueur]=(1) OR [en_vigueur]=(0)) AND ([applicable_presentation]=(1) OR [applicable_presentation]=(0))),
    CONSTRAINT [fk_norme_abroge_par] FOREIGN KEY ([abroge_par]) REFERENCES [dbo].[ref_norme] ([code])
);


GO

CREATE   TRIGGER dbo.[tr_ref_norme_garde]
ON dbo.[ref_norme]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_norme',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_norme_horodatage]
ON dbo.[ref_norme]
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
    FROM dbo.[ref_norme] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

