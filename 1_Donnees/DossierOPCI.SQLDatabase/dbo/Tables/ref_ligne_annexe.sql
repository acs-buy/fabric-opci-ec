CREATE TABLE [dbo].[ref_ligne_annexe] (
    [article]         VARCHAR (10)   NOT NULL,
    [code]            VARCHAR (24)   NOT NULL,
    [libelle]         NVARCHAR (400) NOT NULL,
    [niveau]          INT            NOT NULL,
    [type_ligne]      VARCHAR (14)   NOT NULL,
    [signe]           VARCHAR (4)    NULL,
    [racines]         VARCHAR (300)  NULL,
    [racines_exclues] VARCHAR (300)  NULL,
    [sens]            VARCHAR (8)    NULL,
    [formule]         NVARCHAR (300) NULL,
    [renvoi]          NVARCHAR (600) NULL,
    [ordre]           INT            NOT NULL,
    [modifie_par]     NVARCHAR (400) NULL,
    [modifie_le]      DATETIME2 (3)  NULL,
    [globalisable]    INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_ref_ligne_annexe] PRIMARY KEY CLUSTERED ([article] ASC, [code] ASC),
    CONSTRAINT [ck_ligne_annexe_signe] CHECK ([signe] IS NULL OR ([signe]='=' OR [signe]='+/-' OR [signe]='-' OR [signe]='+')),
    CONSTRAINT [ck_ligne_annexe_type] CHECK ([type_ligne]='TOTAL' OR [type_ligne]='SAISIE' OR [type_ligne]='CALCUL' OR [type_ligne]='RUBRIQUE'),
    CONSTRAINT [fk_ligne_annexe_tableau] FOREIGN KEY ([article]) REFERENCES [dbo].[ref_tableau_annexe] ([article]),
    CONSTRAINT [uq_ref_ligne_annexe_ordre] UNIQUE NONCLUSTERED ([article] ASC, [ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_ligne_annexe_garde]
ON dbo.[ref_ligne_annexe]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_ligne_annexe',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ligne_annexe_horodatage]
ON dbo.[ref_ligne_annexe]
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
    FROM dbo.[ref_ligne_annexe] t
    JOIN inserted i ON t.[article] = i.[article] AND t.[code] = i.[code];
END;

GO

