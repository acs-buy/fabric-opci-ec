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
    CONSTRAINT [ck_ref_article_prefixe_du_code] CHECK ([source]<>'CMF' OR (left([article],(1))='D' OR left([article],(1))='L' OR left([article],(1))='R')),
    CONSTRAINT [ck_ref_article_section] CHECK ([section]>=(1) AND [section]<=(9)),
    CONSTRAINT [ck_ref_article_source] CHECK ([source]='CMF' OR [source]='ANC'),
    CONSTRAINT [ck_ref_article_titre] CHECK ([titre]>=(1) AND [titre]<=(5)),
    CONSTRAINT [fk_article_norme] FOREIGN KEY ([norme]) REFERENCES [dbo].[ref_norme] ([code]),
    CONSTRAINT [uq_ref_article_source_ordre] UNIQUE NONCLUSTERED ([source] ASC, [ordre] ASC)
);


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
    -- Objet n° 16 de l'ecran 5 (script 317) : l'auteur est celui que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte, a la longueur de la colonne modifie_par.
    UPDATE t SET modifie_par = CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), modifie_le = SYSUTCDATETIME()
    FROM dbo.[ref_article] t
    JOIN inserted i ON t.[article] = i.[article];
END;

GO

CREATE   TRIGGER dbo.[tr_ref_article_garde]
ON dbo.[ref_article]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    -- Objet n° 16 de l'ecran 5 (script 317) : l'identite jugee est celle que la procedure d'ecran pose dans le
    -- contexte par, a defaut le compte connecte. Le CAST est exige : un sql_variant passe nu a
    -- fn_peut_ecrire_referentiel rend le Msg 257.
    IF dbo.fn_peut_ecrire_referentiel('ref_article',
                                      CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400))) = 1 RETURN;
    -- Objet n° 17 : le refus s'inscrit dans journal_refus avant d'etre leve. Le ROLLBACK precede
    -- l'inscription, que le THROW annulerait sinon avec l'ecriture refusee (pas de transaction autonome) ;
    -- sous une Data function, la fonction annule aussi l'inscription, puis journalise le refus apres son
    -- propre rollback (script 220). refuse_pour est un nvarchar(200) : l'identite y est coupee a 200
    -- caracteres, une ecriture plus longue y serait refusee et remplacerait le 50074.
    DECLARE @m NVARCHAR (2000) = N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.';
    ROLLBACK TRANSACTION;
    INSERT INTO dbo.journal_refus (procedure_nom, message, refuse_pour, refuse_le)
    VALUES ('tr_ref_article_garde', @m, LEFT(CAST(COALESCE(SESSION_CONTEXT(N'par'), SUSER_SNAME()) AS NVARCHAR (400)), 200), SYSUTCDATETIME());
    SET @m = REPLACE(@m, N'%', N'%%');
    THROW 50074, @m, 1;
END;

GO

