CREATE TABLE [dbo].[ref_ligne_etat] (
    [etat]        VARCHAR (14)   NOT NULL,
    [code]        VARCHAR (20)   NOT NULL,
    [libelle]     NVARCHAR (300) NOT NULL,
    [type_ligne]  VARCHAR (14)   NOT NULL,
    [romain]      VARCHAR (6)    NULL,
    [racines]     VARCHAR (300)  NULL,
    [sens]        VARCHAR (8)    NULL,
    [formule]     NVARCHAR (200) NULL,
    [renvoi]      NVARCHAR (400) NULL,
    [article]     NVARCHAR (40)  NOT NULL,
    [ordre]       INT            NOT NULL,
    [modifie_par] NVARCHAR (400) NULL,
    [modifie_le]  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_ligne_etat] PRIMARY KEY CLUSTERED ([etat] ASC, [code] ASC),
    CONSTRAINT [ck_ligne_detail] CHECK ([type_ligne]<>'DETAIL' OR [racines] IS NOT NULL OR [formule] IS NOT NULL),
    CONSTRAINT [ck_ligne_etat] CHECK ([etat]='RESULTAT' OR [etat]='BILAN_PASSIF' OR [etat]='BILAN_ACTIF'),
    CONSTRAINT [ck_ligne_sens] CHECK ([sens] IS NULL OR ([sens]='CREDIT' OR [sens]='DEBIT')),
    CONSTRAINT [ck_ligne_type] CHECK ([type_ligne]='RESULTAT' OR [type_ligne]='TOTAL' OR [type_ligne]='DETAIL' OR [type_ligne]='RUBRIQUE'),
    CONSTRAINT [uq_ref_ligne_etat_ordre] UNIQUE NONCLUSTERED ([etat] ASC, [ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_ligne_etat_garde]
ON dbo.[ref_ligne_etat]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_ligne_etat',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ligne_etat_horodatage]
ON dbo.[ref_ligne_etat]
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
    FROM dbo.[ref_ligne_etat] t
    JOIN inserted i ON t.[etat] = i.[etat] AND t.[code] = i.[code];
END;

GO

