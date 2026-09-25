CREATE TABLE [dbo].[ref_compte_entite] (
    [entite]            VARCHAR (20)   NOT NULL,
    [compte_entite]     VARCHAR (20)   NOT NULL,
    [libelle_entite]    NVARCHAR (200) NULL,
    [compte_modele]     VARCHAR (20)   NOT NULL,
    [rattache_par]      NVARCHAR (200) NOT NULL,
    [rattache_le]       DATETIME2 (3)  DEFAULT (sysutcdatetime()) NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [entite_liee]       VARCHAR (20)   NULL,
    [porte_intragroupe] INT            CONSTRAINT [df_rce_intragroupe] DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([entite] ASC, [compte_entite] ASC),
    CONSTRAINT [ck_rce_intragroupe] CHECK ([porte_intragroupe]=(1) OR [porte_intragroupe]=(0)),
    CONSTRAINT [fk_rce_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rce_entite_liee] FOREIGN KEY ([entite_liee]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_rce_modele] FOREIGN KEY ([compte_modele]) REFERENCES [dbo].[ref_compte] ([compte])
);


GO

CREATE   TRIGGER dbo.tr_rattachement_meme_classe
ON dbo.ref_compte_entite
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        WHERE LEFT(i.compte_entite, 1) <> LEFT(i.compte_modele, 1)
          AND i.compte_entite <> i.compte_modele
          AND NOT EXISTS (
              SELECT 1 FROM dbo.ref_correspondance_plan c
              WHERE c.compte_source = i.compte_entite
                AND c.compte_modele = i.compte_modele)
    )
        THROW 50048, 'Rattachement refuse : le compte de l''entite et le compte modele ne sont pas de la meme classe, et aucune correspondance n''est declaree entre les 2 plans. Une traduction qui change de classe se justifie : la declarer dans dbo.ref_correspondance_plan avec son motif, comme le passage du compte 4551 du PCG au compte 512 du plan de l''article 411-3.', 1;
END

GO

CREATE   TRIGGER dbo.[tr_ref_compte_entite_garde]
ON dbo.[ref_compte_entite]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_compte_entite',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_compte_entite_horodatage]
ON dbo.[ref_compte_entite]
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
    FROM dbo.[ref_compte_entite] t
    JOIN inserted i ON t.[entite] = i.[entite] AND t.[compte_entite] = i.[compte_entite];
END;

GO

