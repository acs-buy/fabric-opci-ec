CREATE TABLE [dbo].[ecriture_axe] (
    [ecriture_id] INT          NOT NULL,
    [entite]      VARCHAR (20) NULL,
    [code_actif]  VARCHAR (20) NULL,
    [code_projet] VARCHAR (20) NULL,
    [code_lot]    VARCHAR (20) NULL,
    PRIMARY KEY CLUSTERED ([ecriture_id] ASC),
    FOREIGN KEY ([code_actif]) REFERENCES [dbo].[actif] ([code]),
    FOREIGN KEY ([ecriture_id]) REFERENCES [dbo].[ecriture] ([id]),
    CONSTRAINT [fk_ecriture_axe_entite] FOREIGN KEY ([entite]) REFERENCES [dbo].[ref_entite] ([code])
);


GO

CREATE NONCLUSTERED INDEX [ix_ecriture_axe_actif]
    ON [dbo].[ecriture_axe]([code_actif] ASC);


GO


CREATE   TRIGGER dbo.tr_ecriture_axe_annexe_retard ON dbo.ecriture_axe
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted) RETURN;
    ;WITH ch AS (
        SELECT ecriture_id, code_actif FROM inserted
        EXCEPT SELECT ecriture_id, code_actif FROM deleted
        UNION ALL
        SELECT * FROM (SELECT ecriture_id, code_actif FROM deleted EXCEPT SELECT ecriture_id, code_actif FROM inserted) d
    ),
    x AS (SELECT q.x, q.vehicule, COUNT(*) AS n FROM (SELECT l.entite AS x, CAST(NULL AS BIT) AS vehicule FROM ch JOIN dbo.ecriture e ON e.id = ch.ecriture_id JOIN dbo.lot_ecritures l ON l.id = e.lot_id WHERE l.statut IN ('VALIDE', 'EXPORTE', 'PUBLIE')) q GROUP BY q.x, q.vehicule)
    INSERT INTO dbo.annexe_retard (entite, ecrit_le, origine, lignes)
    SELECT v.entite, SYSUTCDATETIME(), N'ecriture_axe', SUM(x.n)
    FROM x CROSS APPLY dbo.fn_ann_vehicules(x.x, 0, x.vehicule) v
    GROUP BY v.entite;
END;

GO

