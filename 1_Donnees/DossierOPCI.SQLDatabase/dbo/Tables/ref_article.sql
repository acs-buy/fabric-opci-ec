CREATE TABLE [dbo].[ref_article] (
    [article]        VARCHAR (10)   NOT NULL,
    [intitule]       NVARCHAR (200) NULL,
    [titre]          INT            NULL,
    [chapitre]       INT            NULL,
    [section]        INT            NULL,
    [ordre]          INT            NOT NULL,
    [dans_perimetre] INT            DEFAULT ((1)) NOT NULL,
    [source]         VARCHAR (20)   DEFAULT ('ANC') NOT NULL,
    [modifie_par]    NVARCHAR (400) NULL,
    [modifie_le]     DATETIME2 (3)  NULL,
    [norme]          VARCHAR (14)   NULL,
    CONSTRAINT [pk_ref_article] PRIMARY KEY CLUSTERED ([article] ASC),
    CONSTRAINT [ck_ref_article_chapitre] CHECK ([chapitre]>=(1) AND [chapitre]<=(9)),
    CONSTRAINT [ck_ref_article_decoupage_selon_source] CHECK ([source]='ANC' AND [titre] IS NOT NULL AND [chapitre] IS NOT NULL AND [section] IS NOT NULL OR [source]<>'ANC' AND [titre] IS NULL AND [chapitre] IS NULL AND [section] IS NULL),
    CONSTRAINT [ck_ref_article_numero_coherent] CHECK ([source]<>'ANC' OR left([article],(1))=CONVERT([varchar](1),[titre]) AND substring([article],(2),(1))=CONVERT([varchar](1),[chapitre]) AND substring([article],(3),(1))=CONVERT([varchar](1),[section])),
    CONSTRAINT [ck_ref_article_perimetre] CHECK ([dans_perimetre]=(1) OR [dans_perimetre]=(0)),
    CONSTRAINT [ck_ref_article_prefixe_du_code] CHECK ([source]<>'CMF' OR (left([article],(1))='R' OR left([article],(1))='L')),
    CONSTRAINT [ck_ref_article_section] CHECK ([section]>=(1) AND [section]<=(9)),
    CONSTRAINT [ck_ref_article_source] CHECK ([source]='CMF' OR [source]='ANC'),
    CONSTRAINT [ck_ref_article_titre] CHECK ([titre]>=(1) AND [titre]<=(5)),
    CONSTRAINT [fk_article_norme] FOREIGN KEY ([norme]) REFERENCES [dbo].[ref_norme] ([code]),
    CONSTRAINT [uq_ref_article_source_ordre] UNIQUE NONCLUSTERED ([source] ASC, [ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_article_garde]
ON dbo.[ref_article]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_article',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_article_horodatage]
ON dbo.[ref_article]
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
    FROM dbo.[ref_article] t
    JOIN inserted i ON t.[article] = i.[article];
END;

GO

