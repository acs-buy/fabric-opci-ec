CREATE TABLE [dbo].[ref_nature_actif] (
    [nature]            VARCHAR (40)   NOT NULL,
    [libelle]           NVARCHAR (200) NOT NULL,
    [methode]           NVARCHAR (300) NOT NULL,
    [article]           VARCHAR (40)   NOT NULL,
    [expertise_requise] SMALLINT       NOT NULL,
    [modifie_par]       NVARCHAR (400) NULL,
    [modifie_le]        DATETIME2 (3)  NULL,
    [reference_id]      INT            NULL,
    CONSTRAINT [pk_ref_nature_actif] PRIMARY KEY CLUSTERED ([nature] ASC),
    CONSTRAINT [ck_rna_expertise] CHECK ([expertise_requise]=(1) OR [expertise_requise]=(0)),
    CONSTRAINT [fk_nature_reference] FOREIGN KEY ([reference_id]) REFERENCES [dbo].[ref_reference] ([id])
);


GO


-- --- 5 : le verrou, une reference abrogee ne s'emploie pas -----------
-- Rattacher une nature d'actif a un article d'un reglement abroge
-- ferait citer par la solution un texte qui ne vaut plus. C'est
-- precisement le piege que la version precedente du memoire a paye, en
-- citant massivement le reglement ANC 2014-06.
CREATE   TRIGGER dbo.tr_nature_reference_en_vigueur
ON dbo.ref_nature_actif
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.ref_reference r ON r.id = i.reference_id
        JOIN dbo.ref_norme n ON n.code = r.norme
        WHERE n.en_vigueur = 0
    )
        THROW 50058, 'Rattachement refuse : la reference designee releve d''un texte abroge. Lire dbo.ref_norme pour le texte qui l''abroge, et rattacher la nature a l''article correspondant du texte en vigueur.', 1;
END

GO

CREATE   TRIGGER dbo.[tr_ref_nature_actif_garde]
ON dbo.[ref_nature_actif]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_nature_actif',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_nature_actif_horodatage]
ON dbo.[ref_nature_actif]
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
    FROM dbo.[ref_nature_actif] t
    JOIN inserted i ON t.[nature] = i.[nature];
END;

GO

