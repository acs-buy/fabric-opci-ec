CREATE TABLE [dbo].[ref_ratio] (
    [code]             VARCHAR (20)    NOT NULL,
    [libelle]          NVARCHAR (200)  NOT NULL,
    [sens]             VARCHAR (10)    NOT NULL,
    [seuil]            DECIMAL (9, 4)  NOT NULL,
    [forme_vehicule]   VARCHAR (20)    NULL,
    [article]          NVARCHAR (60)   NOT NULL,
    [citation]         NVARCHAR (2000) NOT NULL,
    [source_du_seuil]  VARCHAR (20)    NOT NULL,
    [lu_le]            DATE            NULL,
    [calculable]       INT             NOT NULL,
    [note]             NVARCHAR (800)  NULL,
    [calcul_a_valider] INT             DEFAULT ((1)) NOT NULL,
    [ordre]            INT             NOT NULL,
    [modifie_par]      NVARCHAR (400)  NULL,
    [modifie_le]       DATETIME2 (3)   NULL,
    CONSTRAINT [pk_ref_ratio] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_ratio_a_valider] CHECK ([calcul_a_valider]=(1) OR [calcul_a_valider]=(0)),
    CONSTRAINT [ck_ratio_calculable] CHECK ([calculable]=(1) OR [calculable]=(0)),
    CONSTRAINT [ck_ratio_lu] CHECK ([source_du_seuil]<>'TEXTE' OR [lu_le] IS NOT NULL),
    CONSTRAINT [ck_ratio_sens] CHECK ([sens]='MAXIMUM' OR [sens]='MINIMUM'),
    CONSTRAINT [ck_ratio_source] CHECK ([source_du_seuil]='CABINET' OR [source_du_seuil]='PROSPECTUS' OR [source_du_seuil]='TEXTE'),
    CONSTRAINT [uq_ref_ratio_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_ratio_garde]
ON dbo.[ref_ratio]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF dbo.fn_peut_ecrire_referentiel('ref_ratio',
                                      SUSER_SNAME()) = 1 RETURN;
    THROW 50074,
        N'Écriture refusée : la modification de ce référentiel du cabinet demande le rôle associé. Votre compte ne porte aucun rôle de ce genre sur les dossiers ouverts. Demander à l''associé de porter la modification, ou de vous attribuer le rôle.',
        1;
END;

GO

CREATE   TRIGGER dbo.[tr_ref_ratio_horodatage]
ON dbo.[ref_ratio]
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
    FROM dbo.[ref_ratio] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

