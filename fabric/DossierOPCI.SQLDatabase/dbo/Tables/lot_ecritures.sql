CREATE TABLE [dbo].[lot_ecritures] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [famille]            VARCHAR (10)    NOT NULL,
    [portee]             VARCHAR (10)    NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [statut]             VARCHAR (10)    DEFAULT ('PROPOSE') NOT NULL,
    [version_regles]     VARCHAR (20)    NULL,
    [motif]              NVARCHAR (400)  NULL,
    [cree_par]           NVARCHAR (200)  NOT NULL,
    [cree_le]            DATETIME2 (7)   DEFAULT (sysutcdatetime()) NOT NULL,
    [statut_par]         NVARCHAR (200)  NULL,
    [statut_le]          DATETIME2 (3)   NULL,
    [question_id]        INT             NULL,
    [feuille_cote]       VARCHAR (30)    NULL,
    [piece_id]           INT             NULL,
    [import_id]          INT             NULL,
    [perime_le]          DATETIME2 (3)   NULL,
    [perime_motif]       NVARCHAR (600)  NULL,
    [perime_par]         NVARCHAR (200)  NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_entite_obligatoire] CHECK ([entite] IS NOT NULL),
    CONSTRAINT [ck_famille] CHECK ([famille]='IMPORTEE' OR [famille]='DECIDEE' OR [famille]='DERIVABLE'),
    CONSTRAINT [ck_lot_peremption_motivee] CHECK ([perime_le] IS NULL OR [perime_motif] IS NOT NULL),
    CONSTRAINT [ck_lot_source_par_famille] CHECK ([famille]='IMPORTEE' AND [import_id] IS NOT NULL OR [famille]='DECIDEE' AND [feuille_cote] IS NOT NULL OR [famille]='DERIVABLE' AND [feuille_cote] IS NOT NULL),
    CONSTRAINT [ck_portee] CHECK ([portee]='ENTITE'),
    CONSTRAINT [ck_statut] CHECK ([statut]='PUBLIE' OR [statut]='EXPORTE' OR [statut]='REJETE' OR [statut]='VALIDE' OR [statut]='PROPOSE'),
    CONSTRAINT [ck_version_si_derivable] CHECK ([famille]<>'DERIVABLE' OR [version_regles] IS NOT NULL),
    CONSTRAINT [fk_lot_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_lot_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code]),
    CONSTRAINT [fk_lot_feuille] FOREIGN KEY ([feuille_cote], [arrete], [entite]) REFERENCES [dbo].[feuille_travail] ([cote], [arrete], [entite]),
    CONSTRAINT [fk_lot_import] FOREIGN KEY ([import_id]) REFERENCES [dbo].[import_fec] ([id]),
    CONSTRAINT [fk_lot_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [fk_lot_question] FOREIGN KEY ([question_id]) REFERENCES [dbo].[ref_question] ([id])
);


GO



-- ---------------------------------------------------------------------
-- BLOC 6 : tr_lot_ecritures_non_regenerable. Le refus de supprimer la
-- ligne d'un lot déjà remis. SEUL DANS SON LOT.
-- ---------------------------------------------------------------------
CREATE   TRIGGER dbo.tr_lot_ecritures_non_regenerable
ON dbo.lot_ecritures
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF (ROWCOUNT_BIG() = 0)
        RETURN;

    DECLARE @statut VARCHAR (10) = (
        SELECT MAX(d.statut)
          FROM deleted d
         WHERE d.statut IN ('EXPORTE', 'PUBLIE'));

    IF @statut IS NOT NULL
    BEGIN
        DECLARE @msg NVARCHAR (700) =
            N'Suppression refusee par tr_lot_ecritures_non_regenerable de '
            + N'63_SQL/33_export_fec.sql : un lot supprime porte le statut '
            + @statut + N', il est deja remis. Un lot exporte ou publie '
            + N'n''est plus regenerable : sa correction passe par une '
            + N'ecriture inverse dans un nouveau lot, jamais par une '
            + N'destruction. La liste des lots concernes est rendue par '
            + N'dbo.v_lot_non_regenerable.';
        THROW 50019, @msg, 6;
    END
END

GO


-- LA PEREMPTION D'UNE SYNTHESE, que le point O1 exige : un lot vise
-- APRES la proposition change l'actif net, donc la synthese ne vaut
-- plus. Le declencheur la marque perimee.
CREATE   TRIGGER dbo.tr_lot_perime_synthese
ON dbo.lot_ecritures
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted i JOIN deleted d ON d.id = i.id
                   WHERE i.statut = 'VALIDE' AND d.statut <> 'VALIDE')
        RETURN;
    UPDATE s
    SET perime_le = SYSUTCDATETIME(),
        perime_motif = N'Un lot de cet arrêté a été visé après la '
                     + N'proposition de la synthèse : l''actif net a changé, '
                     + N'la synthèse doit être proposée de nouveau.'
    FROM dbo.synthese_proposee s
    JOIN inserted i ON i.entite = s.entite AND i.arrete = s.arrete
    WHERE s.perime_le IS NULL AND s.propose_le < SYSUTCDATETIME();
END;

GO

