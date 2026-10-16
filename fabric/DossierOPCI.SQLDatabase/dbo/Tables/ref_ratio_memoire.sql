CREATE TABLE [dbo].[ref_ratio_memoire] (
    [code]                        VARCHAR (30)   NOT NULL,
    [ordre]                       INT            NOT NULL,
    [famille]                     NVARCHAR (40)  NOT NULL,
    [libelle]                     NVARCHAR (120) NOT NULL,
    [article]                     NVARCHAR (120) NOT NULL,
    [limite_texte]                NVARCHAR (60)  NOT NULL,
    [article_calcul]              NVARCHAR (200) NULL,
    [dates_respect]               NVARCHAR (400) NULL,
    [dates_respect_professionnel] NVARCHAR (400) NULL,
    [forme_vehicule]              VARCHAR (10)   NULL,
    [statut_grand_public]         VARCHAR (12)   NOT NULL,
    [fondement_grand_public]      NVARCHAR (600) NULL,
    [statut_professionnel]        VARCHAR (12)   NOT NULL,
    [fondement_professionnel]     NVARCHAR (600) NULL,
    [citation]                    NVARCHAR (800) NOT NULL,
    [lu_le]                       DATE           NOT NULL,
    [modifie_par]                 NVARCHAR (400) NULL,
    [modifie_le]                  DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_ratio_memoire] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_rrm_statut_gp] CHECK ([statut_grand_public]='CONDITION' OR [statut_grand_public]='APPLICABLE'),
    CONSTRAINT [ck_rrm_statut_pro] CHECK ([statut_professionnel]='A_ARRETER' OR [statut_professionnel]='RETENUE' OR [statut_professionnel]='SANS_OBJET' OR [statut_professionnel]='APPLICABLE'),
    CONSTRAINT [uq_ref_ratio_memoire_libelle] UNIQUE NONCLUSTERED ([libelle] ASC),
    CONSTRAINT [uq_ref_ratio_memoire_ordre] UNIQUE NONCLUSTERED ([ordre] ASC)
);


GO

CREATE   TRIGGER dbo.[tr_ref_ratio_memoire_horodatage]
ON dbo.[ref_ratio_memoire]
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
    FROM dbo.[ref_ratio_memoire] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

