CREATE TABLE [dbo].[expertise] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [code_actif]      VARCHAR (20)    NOT NULL,
    [date_valeur]     DATE            NOT NULL,
    [valeur_actuelle] DECIMAL (19, 2) NOT NULL,
    [expert]          NVARCHAR (200)  NULL,
    [methode]         NVARCHAR (200)  NULL,
    [piece_id]        INT             NULL,
    [enregistre_par]  NVARCHAR (200)  NULL,
    [enregistre_le]   DATETIME2 (3)   NULL,
    [version]         INT             NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_expertise_enregistrement] CHECK ([enregistre_par] IS NOT NULL AND [enregistre_le] IS NOT NULL AND [version] IS NOT NULL),
    FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_expertise_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [uq_expertise] UNIQUE NONCLUSTERED ([code_actif] ASC, [date_valeur] ASC)
);


GO


-- --- 7 : le verrou K2, une expertise perime le lot propose ----------
-- Elle ne le supprime pas et ne l'annule pas : elle le marque. La
-- decision de regenerer ou de viser quand meme revient au chef de
-- mission, qui la prend en connaissance du fait.
CREATE   TRIGGER dbo.tr_expertise_perime_lot
ON dbo.expertise
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE l
       SET perime_le = SYSUTCDATETIME(),
           perime_motif = N'Une expertise a ete enregistree sur '
               + (SELECT TOP (1) i.code_actif FROM inserted i
                  JOIN dbo.actif a ON a.code = i.code_actif
                  WHERE a.entite_detentrice = l.entite)
               + N' apres la generation de ce lot. Le lot ne reflete plus '
               + N'son perimetre : le regenerer, ou viser en connaissance '
               + N'du fait.',
           perime_par = N'automatique : tr_expertise_perime_lot'
    FROM dbo.lot_ecritures l
    WHERE l.statut = 'PROPOSE'
      AND l.famille = 'DERIVABLE'
      AND l.perime_le IS NULL
      AND EXISTS (SELECT 1 FROM inserted i
                  JOIN dbo.actif a ON a.code = i.code_actif
                  WHERE a.entite_detentrice = l.entite
                    AND i.enregistre_le > l.cree_le);
END

GO

