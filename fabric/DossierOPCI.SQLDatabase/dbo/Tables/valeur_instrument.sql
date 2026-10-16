CREATE TABLE [dbo].[valeur_instrument] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [entite]           VARCHAR (20)    NOT NULL,
    [arrete]           VARCHAR (20)    NOT NULL,
    [code_actif]       VARCHAR (20)    NOT NULL,
    [compte]           VARCHAR (20)    NOT NULL,
    [valeur_comptable] DECIMAL (19, 2) NOT NULL,
    [valeur_actuelle]  DECIMAL (19, 2) NOT NULL,
    [source]           NVARCHAR (200)  NOT NULL,
    [saisi_par]        NVARCHAR (200)  NOT NULL,
    [saisi_le]         DATETIME2 (3)   DEFAULT (sysutcdatetime()) NOT NULL,
    [piece_id]         INT             NULL,
    CONSTRAINT [pk_valeur_instrument] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [ck_vi_classe_3] CHECK (left([compte],(1))='3'),
    CONSTRAINT [fk_vi_actif] FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    CONSTRAINT [fk_vi_arrete] FOREIGN KEY ([entite], [arrete]) REFERENCES [dbo].[ref_arrete] ([entite], [arrete]),
    CONSTRAINT [fk_vi_compte] FOREIGN KEY ([compte]) REFERENCES [dbo].[ref_compte] ([compte]),
    CONSTRAINT [fk_vi_piece] FOREIGN KEY ([piece_id]) REFERENCES [dbo].[piece] ([id]),
    CONSTRAINT [uq_valeur_instrument] UNIQUE NONCLUSTERED ([entite] ASC, [arrete] ASC, [code_actif] ASC)
);


GO


CREATE   TRIGGER dbo.tr_valeur_instrument_annexe_retard ON dbo.valeur_instrument
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT id, arrete, code_actif, entite, valeur_actuelle FROM inserted
        EXCEPT SELECT id, arrete, code_actif, entite, valeur_actuelle FROM deleted
        UNION ALL
        SELECT * FROM (SELECT id, arrete, code_actif, entite, valeur_actuelle FROM deleted EXCEPT SELECT id, arrete, code_actif, entite, valeur_actuelle FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT ch.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'valeur_instrument', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

