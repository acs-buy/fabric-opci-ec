CREATE TABLE [dbo].[evaluation_actif] (
    [id]                 INT             IDENTITY (1, 1) NOT NULL,
    [code_actif]         VARCHAR (20)    NOT NULL,
    [entite]             VARCHAR (20)    NOT NULL,
    [arrete]             VARCHAR (20)    NOT NULL,
    [valeur_retenue]     DECIMAL (19, 2) NOT NULL,
    [source]             VARCHAR (20)    NOT NULL,
    [expertise_id]       INT             NULL,
    [motif_ecart]        NVARCHAR (600)  NULL,
    [propose_par]        NVARCHAR (200)  NOT NULL,
    [propose_le]         DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [etat]               VARCHAR (10)    DEFAULT ('PROPOSE') NOT NULL,
    [vise_par]           NVARCHAR (200)  NULL,
    [vise_le]            DATETIME2 (3)   NULL,
    [motif_renvoi]       NVARCHAR (600)  NULL,
    [message_ecran]      NVARCHAR (2000) NULL,
    [message_ecran_le]   DATETIME2 (3)   NULL,
    [message_ecran_pour] NVARCHAR (200)  NULL,
    [piece_id]           INT             NULL,
    CONSTRAINT [pk_evaluation_actif] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ev_ecart_motive] CHECK ([expertise_id] IS NULL OR [motif_ecart] IS NOT NULL OR [source]='EXPERTISE'),
    CONSTRAINT [ck_ev_etat] CHECK ([etat]='RENVOYE' OR [etat]='VISE' OR [etat]='PROPOSE'),
    CONSTRAINT [ck_ev_etat_vise] CHECK ([etat]='PROPOSE' OR [vise_par] IS NOT NULL AND [vise_le] IS NOT NULL),
    CONSTRAINT [ck_ev_expertise_nommee] CHECK ([source]<>'EXPERTISE' OR [expertise_id] IS NOT NULL),
    CONSTRAINT [ck_ev_source] CHECK ([source]='PRIX_CONVENU' OR [source]='PRIX_REVIENT' OR [source]='NOMINAL' OR [source]='MARCHE' OR [source]='MODELE' OR [source]='EXPERTISE'),
    CONSTRAINT [fk_ev_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_ev_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ev_expertise] FOREIGN KEY ([expertise_id]) REFERENCES [dbo].[expertise] ([id]),
    CONSTRAINT [fk_ev_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [uq_evaluation_actif] UNIQUE NONCLUSTERED ([code_actif] ASC, [entite] ASC, [arrete] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ix_evaluation_actif_arrete]
    ON [dbo].[evaluation_actif]([entite] ASC, [arrete] ASC);


GO


CREATE   TRIGGER dbo.tr_evaluation_actif_annexe_retard ON dbo.evaluation_actif
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, arrete, code_actif, entite, etat, source, valeur_retenue, vise_par FROM inserted
        EXCEPT SELECT id, arrete, code_actif, entite, etat, source, valeur_retenue, vise_par FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, arrete, code_actif, entite, etat, source, valeur_retenue, vise_par FROM deleted EXCEPT SELECT id, arrete, code_actif, entite, etat, source, valeur_retenue, vise_par FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'evaluation_actif', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

