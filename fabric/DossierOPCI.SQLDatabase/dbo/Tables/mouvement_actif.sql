CREATE TABLE [dbo].[mouvement_actif] (
    [id]                  INT             IDENTITY (1, 1) NOT NULL,
    [code_actif]          VARCHAR (20)    NOT NULL,
    [entite]              VARCHAR (20)    NOT NULL,
    [arrete]              VARCHAR (20)    NOT NULL,
    [nature]              VARCHAR (14)    NOT NULL,
    [date_mouvement]      DATE            NOT NULL,
    [montant]             DECIMAL (19, 2) NOT NULL,
    [prix_cession]        DECIMAL (19, 2) NULL,
    [valeur_nette_sortie] DECIMAL (19, 2) NULL,
    [frais]               DECIMAL (19, 2) DEFAULT ((0)) NOT NULL,
    [piece_id]            INT             NULL,
    [saisi_par]           NVARCHAR (200)  NOT NULL,
    [saisi_le]            DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_mouvement_actif] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_ma_cession_complete] CHECK (NOT ([nature]='SORTIE' OR [nature]='CESSION') OR [prix_cession] IS NOT NULL AND [valeur_nette_sortie] IS NOT NULL),
    CONSTRAINT [ck_ma_entree_sans_cession] CHECK (NOT ([nature]='TRAVAUX' OR [nature]='ACQUISITION') OR [prix_cession] IS NULL AND [valeur_nette_sortie] IS NULL),
    CONSTRAINT [ck_ma_montant] CHECK ([montant]>(0)),
    CONSTRAINT [ck_ma_nature] CHECK ([nature]='SORTIE' OR [nature]='CESSION' OR [nature]='TRAVAUX' OR [nature]='ACQUISITION'),
    CONSTRAINT [fk_ma_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_ma_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_ma_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id])
);


GO

CREATE NONCLUSTERED INDEX [ix_mouvement_actif_arrete]
    ON [dbo].[mouvement_actif]([entite] ASC, [arrete] ASC);


GO


CREATE   TRIGGER dbo.tr_mouvement_actif_annexe_retard ON dbo.mouvement_actif
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, code_actif, date_mouvement, entite, frais, montant, nature, prix_cession, valeur_nette_sortie FROM inserted
        EXCEPT SELECT id, code_actif, date_mouvement, entite, frais, montant, nature, prix_cession, valeur_nette_sortie FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, code_actif, date_mouvement, entite, frais, montant, nature, prix_cession, valeur_nette_sortie FROM deleted EXCEPT SELECT id, code_actif, date_mouvement, entite, frais, montant, nature, prix_cession, valeur_nette_sortie FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'mouvement_actif', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

