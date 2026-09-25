CREATE TABLE [dbo].[ref_aide] (
    [code]         VARCHAR (30)   NOT NULL,
    [libelle_lien] NVARCHAR (60)  NOT NULL,
    [titre_page]   NVARCHAR (120) NOT NULL,
    [url]          NVARCHAR (500) NOT NULL,
    [portee]       VARCHAR (10)   NOT NULL,
    [parcours]     VARCHAR (30)   NULL,
    [feuille]      NVARCHAR (60)  NULL,
    [ordre]        INT            NOT NULL,
    [modifie_par]  NVARCHAR (200) NULL,
    [modifie_le]   DATETIME2 (3)  NULL,
    CONSTRAINT [pk_ref_aide] PRIMARY KEY CLUSTERED ([code] ASC),
    CONSTRAINT [ck_ra_coherence] CHECK ([portee]='TOUS' AND [parcours] IS NULL AND [feuille] IS NULL OR [portee]='PARCOURS' AND [parcours] IS NOT NULL AND [feuille] IS NULL OR [portee]='ECRAN' AND [parcours] IS NOT NULL AND [feuille] IS NOT NULL),
    CONSTRAINT [ck_ra_portee] CHECK ([portee]='ECRAN' OR [portee]='PARCOURS' OR [portee]='TOUS'),
    CONSTRAINT [ck_ra_url] CHECK ([url] like 'https://%')
);


GO

CREATE   TRIGGER dbo.[tr_ref_aide_horodatage]
ON dbo.[ref_aide]
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
    FROM dbo.[ref_aide] t
    JOIN inserted i ON t.[code] = i.[code];
END;

GO

